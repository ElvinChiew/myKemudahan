defmodule MyKemudahanWeb.AssetTagLiveTest do
  use MyKemudahanWeb.ConnCase

  import Phoenix.LiveViewTest
  import MyKemudahan.AssetsFixtures

  @create_attrs %{serial: "some serial", status: "some status", tag: "some tag"}
  @update_attrs %{serial: "some updated serial", status: "some updated status", tag: "some updated tag"}
  @invalid_attrs %{serial: nil, status: nil, tag: nil}

  defp create_asset_tag(_) do
    asset_tag = asset_tag_fixture()
    %{asset_tag: asset_tag}
  end

  describe "Index" do
    setup [:create_asset_tag]

    test "lists all asset_tags", %{conn: conn, asset_tag: asset_tag} do
      {:ok, _index_live, html} = live(conn, ~p"/asset_tags")

      assert html =~ "Listing Asset tags"
      assert html =~ asset_tag.serial
    end

    test "saves new asset_tag", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/asset_tags")

      assert index_live |> element("a", "New Asset tag") |> render_click() =~
               "New Asset tag"

      assert_patch(index_live, ~p"/asset_tags/new")

      assert index_live
             |> form("#asset_tag-form", asset_tag: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#asset_tag-form", asset_tag: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/asset_tags")

      html = render(index_live)
      assert html =~ "Asset tag created successfully"
      assert html =~ "some serial"
    end

    test "updates asset_tag in listing", %{conn: conn, asset_tag: asset_tag} do
      {:ok, index_live, _html} = live(conn, ~p"/asset_tags")

      assert index_live |> element("#asset_tags-#{asset_tag.id} a", "Edit") |> render_click() =~
               "Edit Asset tag"

      assert_patch(index_live, ~p"/asset_tags/#{asset_tag}/edit")

      assert index_live
             |> form("#asset_tag-form", asset_tag: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#asset_tag-form", asset_tag: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/asset_tags")

      html = render(index_live)
      assert html =~ "Asset tag updated successfully"
      assert html =~ "some updated serial"
    end

    test "deletes asset_tag in listing", %{conn: conn, asset_tag: asset_tag} do
      {:ok, index_live, _html} = live(conn, ~p"/asset_tags")

      assert index_live |> element("#asset_tags-#{asset_tag.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#asset_tags-#{asset_tag.id}")
    end
  end

  describe "Show" do
    setup [:create_asset_tag]

    test "displays asset_tag", %{conn: conn, asset_tag: asset_tag} do
      {:ok, _show_live, html} = live(conn, ~p"/asset_tags/#{asset_tag}")

      assert html =~ "Show Asset tag"
      assert html =~ asset_tag.serial
    end

    test "updates asset_tag within modal", %{conn: conn, asset_tag: asset_tag} do
      {:ok, show_live, _html} = live(conn, ~p"/asset_tags/#{asset_tag}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Asset tag"

      assert_patch(show_live, ~p"/asset_tags/#{asset_tag}/show/edit")

      assert show_live
             |> form("#asset_tag-form", asset_tag: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#asset_tag-form", asset_tag: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/asset_tags/#{asset_tag}")

      html = render(show_live)
      assert html =~ "Asset tag updated successfully"
      assert html =~ "some updated serial"
    end
  end
end
