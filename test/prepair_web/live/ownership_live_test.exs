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

  ##############################################################################
  ########################## AUTHORIZATION - VISITORS ##########################
  ##############################################################################
  describe "Authorization - visitors" do
    setup [:create_public_ownership]

    ######################## WHAT VISITORS CAN DO ? ############################

    # Nothing

    ####################### WHAT VISITORS CANNOT DO ? ##########################

    # TODO: rework this test for all schemas because it doesn’t really test the
    # edit and delete actions.
    @tag :ownership_liveview
    test "visitors CANNOT list, edit or delete ownerships", %{conn: conn} do
      {:error, detail} = live(conn, ~p"/ownerships")

      assert detail ==
               {:redirect,
                %{
                  to: "/users/log_in",
                  flash: %{"error" => "You must log in to access this page."}
                }}
    end

    @tag :ownership_liveview
    test "visitors CANNOT see or edit an ownership",
         %{conn: conn, public_ownership: public_ownership} do
      {:error, detail} = live(conn, ~p"/ownerships/#{public_ownership.uuid}")

      assert detail ==
               {:redirect,
                %{
                  to: "/users/log_in",
                  flash: %{"error" => "You must log in to access this page."}
                }}
    end

    @tag :ownership_liveview
    test "visitors CANNOT create an ownership", %{conn: conn} do
      {:error, detail} = live(conn, ~p"/ownerships/new")

      assert detail ==
               {:redirect,
                %{
                  to: "/users/log_in",
                  flash: %{"error" => "You must log in to access this page."}
                }}
    end
  end

  ##############################################################################
  ########################### AUTHORIZATION - USERS ############################
  ##############################################################################
  describe "Authorization - users" do
    setup [:register_and_log_in_user, :create_public_ownership]

    ########################### WHAT USERS CAN DO ? ############################

    @tag :ownership_liveview
    test "users CAN see their SELF ownerships",
         %{conn: conn, user: user} do
      ownership = ownership_fixture(user.uuid)
      {:ok, _index_live, html} = live(conn, ~p"/ownerships/#{ownership.uuid}")

      assert html =~ "#{ownership.warranty_duration_m}"
    end

    @tag :ownership_liveview
    test "users CAN create an ownership", %{conn: conn} do
      # A product creation is needed to populate form's dropdowns.
      product = product_fixture()
      {:ok, index_live, _html} = live(conn, ~p"/ownerships/new")

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

    @tag :ownership_liveview
    test "users CAN update their ownerships", %{conn: conn, user: user} do
      ownership = ownership_fixture(user.uuid)

      {:ok, _index_live, html} =
        live(conn, ~p"/ownerships/#{ownership.uuid}/edit")

      assert html =~ "Edit Ownership"

      {:ok, _index_live, html} =
        live(conn, ~p"/ownerships/#{ownership.uuid}/show/edit")

      assert html =~ "Edit Ownership"
    end

    ######################### WHAT USERS CANNOT DO ? ###########################

    @tag :ownership_liveview
    test "users CANNOT list ownerships", %{conn: conn} do
      conn = get(conn, ~p"/ownerships")

      assert conn.status == 403
      assert response(conn, 403) =~ "Forbidden"
    end

    # TODO: Modify the function PrepairWeb.UserAuth.require_self_and_do/4 to
    # make it return a 403 error instead of 302 redirection.
    @tag :ownership_liveview
    test "users CANNOT update another profile's ownership",
         %{conn: conn, public_ownership: public_ownership} do
      conn = get(conn, ~p"/ownerships/#{public_ownership.uuid}/edit")

      assert conn.status == 302

      assert response(conn, 302) =~
               "You are being <a href=\"/\">redirected</a>."

      conn = get(conn, ~p"/ownerships/#{public_ownership.uuid}/show/edit")

      assert conn.status == 302

      assert response(conn, 302) =~
               "You are being <a href=\"/\">redirected</a>."
    end

    # NOTE: There is no specific route to delete an ownership, only an
    # action. Maybe we can still enhance this test.
  end

  ##############################################################################
  ########################## FEATURES TESTS - ADMIN ############################
  ##############################################################################

  describe "Index" do
    setup [
      :create_public_ownership,
      :register_and_log_in_user,
      :make_user_admin
    ]

    @tag :ownership_liveview
    test "lists public ownerships", %{
      conn: conn,
      public_ownership: public_ownership
    } do
      {:ok, _index_live, html} = live(conn, ~p"/ownerships")

      assert html =~ "Listing Public Ownerships"
      assert html =~ public_ownership.profile.username
    end

    @tag :ownership_liveview
    @tag :gettext
    test "index texts are translated to the first language in 'accept-language'
  which match one of the locales defined for the application",
         %{conn: conn, public_ownership: public_ownership} do
      conn = conn |> set_language_to_de_then_fr()
      {:ok, _index_live, html} = live(conn, ~p"/ownerships")

      assert html =~ "Référencement des possessions publiques"
      assert html =~ public_ownership.profile.username
    end

    @tag :ownership_liveview
    @tag :gettext
    test "index texts are not translated ('en' is the default locale) if none
  of the languages in 'accept-language' is part of the locales defined for
  the app",
         %{conn: conn, public_ownership: public_ownership} do
      conn = conn |> set_language_to_unknown()
      {:ok, _index_live, html} = live(conn, ~p"/ownerships")

      assert html =~ "Listing Public Ownerships"
      assert html =~ public_ownership.profile.username
    end

    @tag :ownership_liveview
    test "saves new ownership", %{conn: conn} do
      # A product creation is needed to populate form's dropdowns.
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

    @tag :ownership_liveview
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

    @tag :ownership_liveview
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

  @tag :ownership_liveview
  describe "Show" do
    setup [
      :register_and_log_in_user,
      :create_public_ownership,
      :make_user_admin
    ]

    test "displays ownership", %{conn: conn, public_ownership: public_ownership} do
      {:ok, _show_live, html} = live(conn, ~p"/ownerships/#{public_ownership}")

      assert html =~ "Show Ownership"
    end

    @tag :ownership_liveview
    @tag :gettext
    test "show texts are translated to the first language in 'accept-language'
  which match one of the locales defined for the application",
         %{conn: conn, public_ownership: public_ownership} do
      conn = conn |> set_language_to_de_then_fr()
      {:ok, _index_live, html} = live(conn, ~p"/ownerships/#{public_ownership}")

      assert html =~ "Afficher la possession"
      assert html =~ public_ownership.profile.username
    end

    @tag :ownership_liveview
    @tag :gettext
    test "show texts are not translated ('en' is the default locale) if none
  of the languages in 'accept-language' is part of the locales defined for
  the app",
         %{conn: conn, public_ownership: public_ownership} do
      conn = conn |> set_language_to_unknown()
      {:ok, _index_live, html} = live(conn, ~p"/ownerships/#{public_ownership}")

      assert html =~ "Show Ownership"
      assert html =~ public_ownership.profile.username
    end

    @tag :ownership_liveview
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
