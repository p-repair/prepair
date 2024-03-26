defmodule PrepairWeb.OwnershipLiveTest do
  use PrepairWeb.ConnCase

  alias Prepair.Repo

  import Phoenix.LiveViewTest
  import Prepair.ProfilesFixtures
  import Prepair.ProductsFixtures

  @update_attrs %{
    public: true,
    date_of_purchase: "2024-01-15",
    warranty_duration_m: 43,
    price_of_purchase: 43
  }
  @invalid_attrs %{
    public: false,
    date_of_purchase: nil,
    warranty_duration_m: nil,
    price_of_purchase: nil
  }

  defp create_public_ownership(_) do
    profile_uuid = profile_fixture().uuid

    public_ownership =
      ownership_fixture(profile_uuid, ownership_valid_attrs())
      |> Repo.preload([:product, :profile])

    %{public_ownership: public_ownership}
  end

  describe "Index" do
    setup [:create_public_ownership, :register_and_log_in_user]

    test "lists public ownerships", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/ownerships")

      assert html =~ "Listing Public Ownerships"
    end

    test "saves new ownership", %{conn: conn} do
      product = product_fixture()

      {:ok, index_live, _html} = live(conn, ~p"/ownerships")

      assert index_live |> element("a", "New Ownership") |> render_click() =~
               "New Ownership"

      assert_patch(index_live, ~p"/ownerships/new")

      assert index_live
             |> form("#ownership-form", ownership: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      index_live
      |> form("#ownership-form",
        ownership: %{
          category_uuid: product.category_uuid,
          manufacturer_uuid: product.manufacturer_uuid
        }
      )
      |> render_change()

      assert index_live
             |> form("#ownership-form",
               ownership: %{
                 product_uuid: product.uuid,
                 date_of_purchase: ~D[2023-10-02],
                 warranty_duration_m: 36,
                 price_of_purchase: 500,
                 public: true
               }
             )
             |> render_submit()

      assert_patch(index_live, ~p"/ownerships")

      html = render(index_live)
      assert html =~ "Ownership created successfully"
    end

    test "updates ownership in listing", %{
      conn: conn,
      public_ownership: public_ownership
    } do
      {:ok, index_live, _html} = live(conn, ~p"/ownerships")

      assert index_live
             |> element("#ownerships-#{public_ownership.uuid} a", "Edit")
             |> render_click() =~
               "Edit Ownership"

      assert_patch(index_live, ~p"/ownerships/#{public_ownership}/edit")

      assert index_live
             |> form("#ownership-form", ownership: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#ownership-form", ownership: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/ownerships")

      html = render(index_live)
      assert html =~ "Ownership updated successfully"
    end

    test "deletes ownership in listing", %{
      conn: conn,
      public_ownership: public_ownership
    } do
      {:ok, index_live, _html} = live(conn, ~p"/ownerships")

      assert index_live
             |> element("#ownerships-#{public_ownership.uuid} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#ownerships-#{public_ownership.uuid}")
    end
  end

  describe "Show" do
    setup [:create_public_ownership, :register_and_log_in_user]

    test "displays ownership", %{conn: conn, public_ownership: public_ownership} do
      {:ok, _show_live, html} = live(conn, ~p"/ownerships/#{public_ownership}")

      assert html =~ "Show Ownership"
    end

    test "updates ownership within modal", %{
      conn: conn,
      public_ownership: public_ownership
    } do
      {:ok, show_live, _html} = live(conn, ~p"/ownerships/#{public_ownership}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Ownership"

      assert_patch(show_live, ~p"/ownerships/#{public_ownership}/show/edit")

      assert show_live
             |> form("#ownership-form", ownership: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#ownership-form", ownership: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/ownerships/#{public_ownership}")

      html = render(show_live)
      assert html =~ "Ownership updated successfully"
    end
  end
end
