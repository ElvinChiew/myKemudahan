defmodule MyKemudahanWeb.Requser do
  use MyKemudahanWeb, :live_view

  alias MyKemudahan.Assets

  on_mount {MyKemudahanWeb.UserAuth, :mount_current_user}


  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    all_assets = Assets.list_assets()
                  |> MyKemudahan.Repo.preload(:category)
                  |> Enum.filter(&(Assets.count_available_tags(&1.id) > 0))
    categories = Assets.list_all_categories()

    socket =
      assign(socket,
      assets: all_assets,
      categories: categories,
      selected_category: nil,
      filtered_assets: all_assets,
      requested_items: [],
      total_cost: Decimal.new("0"),
      discount_amount: Decimal.new("0"),
      final_cost: Decimal.new("0"),
      current_page: 1,
      page_size: 10,
      user_id: user.id,
      status: "sent",
      show_modal: false,
      terms_accepted: false,
      is_form_valid: false,
      form_data: %{
        borrow_from: "",
        borrow_to: "",
        purpose: ""
      }
    )

    {:ok, socket}
  end

  def handle_event("filter_by_category", %{"category" => category_id}, socket) do
    filtered_assets = if category_id == "" do
      socket.assigns.assets
    else
      socket.assigns.assets |> Enum.filter(&(&1.category_id == String.to_integer(category_id)))
    end
    {:noreply, assign(socket, filtered_assets: filtered_assets, selected_category: category_id, current_page: 1)}
  end

  def handle_event("submit_form", _params, socket) do
    form_data = socket.assigns.form_data

    with {:ok, parsed_borrow_from} <- Date.from_iso8601(form_data.borrow_from),
         {:ok, parsed_borrow_to} <- Date.from_iso8601(form_data.borrow_to),
         true <- Date.diff(parsed_borrow_to, parsed_borrow_from) == 7 do

      attrs = %{
        borrow_from: parsed_borrow_from,
        borrow_to: parsed_borrow_to,
        purpose: form_data.purpose,
        total_cost: socket.assigns.total_cost,
        user_id: socket.assigns.user_id,
        status: "sent",
        discount_amount: Decimal.new("0"),
        final_cost: socket.assigns.total_cost
      }

      case MyKemudahan.Requests.create_request_with_items(attrs, socket.assigns.requested_items) do
        {:ok, _result} ->
          socket =
            socket
            |> put_flash(:info, "Request submitted successfully!")
            |> assign(
              requested_items: [],
              total_cost: Decimal.new("0"),
              show_modal: false,
              terms_accepted: false,
              is_form_valid: false,
              form_data: %{borrow_from: "", borrow_to: "", purpose: ""} # Reset form
            )

          {:noreply, push_navigate(socket, to: "/reqstatus")}

        {:error, _failed_operation, _failed_value, _changes_so_far} ->
          socket = put_flash(socket, :error, "Something went wrong. Please try again.")
          {:noreply, socket}
      end
    else
      _ ->
        socket = put_flash(socket, :error, "Invalid date format or duration. Borrow period must be exactly 1 week.")
        {:noreply, socket}
    end
  end

  def handle_event("add_item", %{"asset_id" => asset_id_str, "quantity" => quantity_str}, socket) do
    with {asset_id, ""} <- Integer.parse(asset_id_str),
         {quantity, ""} <- Integer.parse(quantity_str),
         true <- quantity > 0,
         asset when not is_nil(asset) <- Enum.find(socket.assigns.assets, &(&1.id == asset_id)) do
      # Enforce quantity not exceeding available tags
      available = Assets.count_available_tags(asset_id)

      cond do
        quantity > available ->
          {:noreply,
           socket
           |> put_flash(:error, "Only #{available} available for #{asset.name}.")}
        true ->
      existing_items = socket.assigns.requested_items
      {existing_item, others} =
        existing_items
        |> Enum.split_with(&(&1.id == asset_id))

      new_quantity =
        case existing_item do
          [%{quantity: q}] -> q + quantity
          _ -> quantity
        end
      if new_quantity > available do
        {:noreply,
         socket
         |> put_flash(:error, "Only #{available} available for #{asset.name}. You already added #{existing_item |> List.first() |> then(&(&1 && &1.quantity || 0))}.")}
      else
        updated_item = %{
          id: asset.id,
          name: asset.name,
          cost_per_unit: asset.cost_per_unit,
          quantity: new_quantity
        }

        new_items = [updated_item | Enum.reject(others, &is_nil/1)]
        new_total = recalc_total(new_items)
        {:noreply, assign(socket, requested_items: new_items, total_cost: new_total)}
      end
      end
    else
      _ -> {:noreply, socket}
    end
  end

  def handle_event("update_item", %{"_id" => id_str, "quantity" => quantity_str}, socket) do
    with {id, ""} <- Integer.parse(id_str),
         {quantity, ""} <- Integer.parse(quantity_str),
         true <- quantity > 0 do
      # Enforce available quantity for the asset
      available = Assets.count_available_tags(id)

      if quantity > available do
        {:noreply,
         socket
         |> put_flash(:error, "Only #{available} available for the selected asset.")}
      else
        updated =
          Enum.map(socket.assigns.requested_items, fn item ->
            if item.id == id, do: %{item | quantity: quantity}, else: item
          end)

        {:noreply, assign(socket, requested_items: updated, total_cost: recalc_total(updated))}
      end
    else
      _ -> {:noreply, socket}
    end
  end

  def handle_event("remove_item", %{"id" => id_str}, socket) do
    case Integer.parse(id_str) do
      {id, ""} ->
        remaining = Enum.reject(socket.assigns.requested_items, &(&1.id == id))
        {:noreply, assign(socket, requested_items: remaining, total_cost: recalc_total(remaining))}
      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("form_change", %{"borrow_from" => borrow_from, "purpose" => purpose}, socket) do
    # Calculate borrow_to as one week from borrow_from
    borrow_to = case Date.from_iso8601(borrow_from) do
      {:ok, date} ->
        Date.add(date, 7) |> Date.to_iso8601()
      {:error, _} ->
        ""  # Keep empty if invalid date
    end

    form_data = %{
      borrow_from: borrow_from,
      borrow_to: borrow_to,
      purpose: purpose
    }
    is_valid = is_form_valid?(form_data)
    {:noreply, assign(socket, form_data: form_data, is_form_valid: is_valid)}
  end

  # Handle individual field changes too
  def handle_event("form_change", %{"borrow_from" => borrow_from}, socket) do
    # Calculate borrow_to as one week from borrow_from
    borrow_to = case Date.from_iso8601(borrow_from) do
      {:ok, date} ->
        Date.add(date, 7) |> Date.to_iso8601()
      {:error, _} ->
        ""  # Keep empty if invalid date
    end

    form_data = %{
      borrow_from: borrow_from,
      borrow_to: borrow_to,
      purpose: socket.assigns.form_data.purpose
    }
    is_valid = is_form_valid?(form_data)
    {:noreply, assign(socket, form_data: form_data, is_form_valid: is_valid)}
  end


  def handle_event("form_change", %{"purpose" => purpose}, socket) do
    form_data = Map.put(socket.assigns.form_data, :purpose, purpose)
    is_valid = is_form_valid?(form_data)
    {:noreply, assign(socket, form_data: form_data, is_form_valid: is_valid)}
  end

  def handle_event("go_to_menu", _params, socket) do
    {:noreply, push_navigate(socket, to: "/usermenu")}
  end

  def handle_event("show_confirmation_modal", _params, socket) do
    {:noreply, assign(socket, show_modal: true, terms_accepted: false)}
  end

  def handle_event("close_modal", _params, socket) do
    {:noreply, assign(socket, show_modal: false, terms_accepted: false)}
  end

  def handle_event("toggle_terms_accepted", _params, socket) do
    {:noreply, assign(socket, terms_accepted: !socket.assigns.terms_accepted)}
  end

  def handle_event("confirm_submit", _params, socket) do
    # Call the original submit_form logic
    handle_event("submit_form", %{}, socket)
  end

  def handle_event("change_page", %{"page" => page_str}, socket) do
    case Integer.parse(page_str) do
      {page, ""} when page > 0 ->
        {:noreply, assign(socket, current_page: page)}
      _ ->
        {:noreply, socket}
    end
  end

  defp recalc_total(items) do
    Enum.reduce(items, Decimal.new("0"), fn item, acc ->
      item_total = Decimal.mult(item.cost_per_unit, Decimal.new(item.quantity))
      Decimal.add(acc, item_total)
    end)
  end

  defp paginated_assets(filtered_assets, current_page, page_size) do
    filtered_assets
    |> Enum.chunk_every(page_size)
    |> Enum.at(current_page - 1, [])
  end

  defp is_form_valid?(form_data) do
    form_data.borrow_from != "" and form_data.purpose != "" and String.trim(form_data.purpose) != ""
  end

end
