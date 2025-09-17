defmodule MyKemudahan.Mailer.RequestEmail do
  import Swoosh.Email

  alias MyKemudahan.Requests

  def approval_email(request) do
    request_with_items = Requests.get_request_with_items!(request.id)

    new()
    |> to({request.user.full_name, request.user.email})
    |> from({"MyKemudahan", "mykemudahan@gmail.com"})
    |> subject("Permohonan Asset Anda Telah Diluluskan")
    |> html_body(render_approval_html(request_with_items))
    |> text_body(render_approval_text(request_with_items))
  end

  def rejection_email(request, rejection_reason) do
    request_with_items = Requests.get_request_with_items!(request.id)

    new()
    |> to({request.user.full_name, request.user.email})
    |> from({"MyKemudahan", "mykemudahan@gmail.com"})
    |> subject("Permohonan Asset Anda Ditolak")
    |> html_body(render_rejection_html(request_with_items, rejection_reason))
    |> text_body(render_rejection_text(request_with_items, rejection_reason))
  end

  defp render_approval_html(request) do
    """
    <h2>Permohonan Asset <span class="text-green-600 underline">Diluluskan</span></h2>
    <p>Permohonan anda telah diluluskan. Sila datang ke kaunter urusetia untuk membuat pembayaran fi pinjaman.</p>

    <h2>Butiran Permohonan:</h2>
    <p><strong>Tarikh:</strong> #{Calendar.strftime(request.borrow_from, "%d-%m-%Y")} hingga #{Calendar.strftime(request.borrow_to, "%d-%m-%Y")}</p>
    <p><strong>Tujuan:</strong> #{request.purpose}</p>

    <h2>Item yang Diluluskan:</h2>
    <ul>
    #{Enum.map(request.request_items, fn item ->
        "<li>#{item.asset.name} - #{item.quantity} unit</li>"
      end) |> Enum.join("")}
    </ul>

    <p>Terima kasih.</p>
    """
  end

  defp render_approval_text(request) do
    """
    Permohonan Asset Diluluskan

    Permohonan anda telah diluluskan. Sila datang ke kaunter urusetia untuk membuat pembayaran fi pinjaman..

    Butiran Permohonan:
    Tarikh: #{Calendar.strftime(request.borrow_from, "%d-%m-%Y")} hingga #{Calendar.strftime(request.borrow_to, "%d-%m-%Y")}
    Tujuan: #{request.purpose}

    Item yang Diluluskan:
    #{Enum.map(request.request_items, fn item ->
        "- #{item.asset.name} - #{item.quantity} unit\\n"
      end) |> Enum.join("")}

    Terima kasih.
    """
  end

  defp render_rejection_html(request, rejection_reason) do
    """
    <h3 class="text-2xl font-bold">
      Permohonan Asset <span class="text-red-600 underline">Ditolak</span>
    </h3>
    <p>Maaf, permohonan anda ditolak.</p>

    <h3>Butiran Penolakan:</h3>
    <p><strong>Sebab:</strong> #{rejection_reason}</p>

    <h3>Butiran Permohonan:</h3>
    <p><strong>Tarikh:</strong> #{Calendar.strftime(request.borrow_from, "%d-%m-%Y")} hingga #{Calendar.strftime(request.borrow_to, "%d-%m-%Y")}</p>
    <p><strong>Tujuan:</strong> #{request.purpose}</p>

    <h3>Item yang Dipohon:</h3>
    <ul>
    #{Enum.map(request.request_items, fn item ->
        "<li>#{item.asset.name} - #{item.quantity} unit</li>"
      end) |> Enum.join("")}
    </ul>

    <p>Sekiranya anda mempunyai sebarang pertanyaan, anda boleh menghubungi
      talian 088 - 273 1875

    <p>Terima kasih.</p>
    <p>MyKemudahan</p>
    """
  end

  defp render_rejection_text(request, rejection_reason) do
    """
    Permohonan Asset Ditolak

    Maaf, permohonan anda tidak dapat diluluskan.

    Butiran Penolakan:
    Sebab: #{rejection_reason}

    Butiran Permohonan:
    Tarikh: #{Calendar.strftime(request.borrow_from, "%d-%m-%Y")} hingga #{Calendar.strftime(request.borrow_to, "%d-%m-%Y")}
    Tujuan: #{request.purpose}

    Item yang Dipohon:
    #{Enum.map(request.request_items, fn item ->
        "- #{item.asset.name} - #{item.quantity} unit\\n"
      end) |> Enum.join("")}

    Terima kasih.
    """
  end
end
