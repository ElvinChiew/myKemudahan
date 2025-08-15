defmodule MyKemudahanWeb.PaginationHelpers do
  def pagination_range(current_page, total_pages) do
    total_pages = trunc(total_pages)
    cond do
      total_pages <= 7 ->
        Enum.to_list(1..total_pages)

      current_page <= 4 ->
        [1, 2, 3, 4, 5, "...", total_pages]

      current_page >= total_pages - 3 ->
        [1, "..."] ++ Enum.to_list(total_pages - 4..total_pages)

      true ->
        [1, "...", current_page - 1, current_page, current_page + 1, "...", total_pages]
    end
  end
end
