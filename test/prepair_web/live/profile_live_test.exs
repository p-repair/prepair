defmodule PrepairWeb.ProfileLiveTest do
  use PrepairWeb.ConnCase

  alias Prepair.LegacyContexts.Profiles

  import Phoenix.LiveViewTest
  import Prepair.LegacyContexts.ProfilesFixtures

  @update_attrs %{
    username: "some updated username",
    newsletter: true,
    people_in_household: 43
  }
  @invalid_attrs %{username: nil, newsletter: false, people_in_household: nil}

  # Est-ce que l’on utilise un create_profile, ou est-ce que l’on récupère
  # le profile depuis user.profile comme j’ai fait pour les tests du controller ?
  # Dans tous les cas un user + profile sont déjà créés avec le :register_an_log_in_user
  defp create_profile(_) do
    profile = profile_fixture()
    %{profile: profile}
  end

  ##############################################################################
  ########################## AUTHORIZATION - VISITORS ##########################
  ##############################################################################
  describe "Authorization - visitors" do
    setup [:create_profile]

    ######################## WHAT VISITORS CAN DO ? ############################

    # Nothing

    ####################### WHAT VISITORS CANNOT DO ? ##########################

    @tag :profile_liveview
    test "visitors CANNOT list, edit or delete profiles", %{conn: conn} do
      {:error, detail} = live(conn, ~p"/profiles")

      assert detail ==
               {:redirect,
                %{
                  to: "/users/log_in",
                  flash: %{"error" => "You must log in to access this page."}
                }}
    end

    @tag :profile_liveview
    test "visitors CANNOT see or edit a profile",
         %{conn: conn, profile: profile} do
      {:error, detail} = live(conn, ~p"/profiles/#{profile.id}")

      assert detail ==
               {:redirect,
                %{
                  to: "/users/log_in",
                  flash: %{"error" => "You must log in to access this page."}
                }}
    end

    # NOTE: There is no route to create a profile, it corresponds to the
    # registration route.
  end

  ##############################################################################
  ########################### AUTHORIZATION - USERS ############################
  ##############################################################################
  describe "Authorization - users" do
    setup [:register_and_log_in_user, :create_profile]

    ########################### WHAT USERS CAN DO ? ############################

    @tag :profile_liveview
    test "users CAN see their self profile",
         %{conn: conn, user: user} do
      self_profile = user.profile

      {:ok, _index_live, html} = live(conn, ~p"/profiles/#{self_profile.id}")

      assert html =~ "#{self_profile.username}"
    end

    @tag :profile_liveview
    test "users CAN update their self profile",
         %{conn: conn, user: user} do
      self_profile = user.profile

      {:ok, _index_live, html} =
        live(conn, ~p"/profiles/#{self_profile.id}/edit")

      assert html =~ "Edit Profile"

      {:ok, _show_live, html} =
        live(conn, ~p"/profiles/#{self_profile.id}/show/edit")

      assert html =~ "Edit Profile"
    end

    # NOTE: Users CAN delete only their SELF profile.
    # To come, with user deletion feature.

    # NOTE: There is no route to create a profile, it corresponds to the
    # registration route.

    ######################### WHAT USERS CANNOT DO ? ###########################

    @tag :profile_liveview
    test "users CANNOT list profiles", %{conn: conn} do
      conn = get(conn, ~p"/profiles")

      assert conn.status == 403
      assert response(conn, 403) =~ "Forbidden"
    end

    @tag :profile_liveview
    test "users CANNOT see another profile",
         %{conn: conn, profile: other_profile} do
      conn = get(conn, ~p"/profiles/#{other_profile.id}")

      assert conn.status == 403
      assert response(conn, 403) =~ "Forbidden"
    end

    @tag :profile_liveview
    test "users CANNOT update another profile",
         %{conn: conn, profile: other_profile} do
      conn = get(conn, ~p"/profiles/#{other_profile.id}/edit")

      assert conn.status == 403
      assert response(conn, 403) =~ "Forbidden"

      conn = get(conn, ~p"/profiles/#{other_profile.id}/show/edit")

      assert conn.status == 403
      assert response(conn, 403) =~ "Forbidden"
    end

    # NOTE: users CANNOT delete a profile which is not their own profile
    # deleting profiles is not a current feature.
  end

  ##############################################################################
  ########################## FEATURES TESTS - ADMIN ############################
  ##############################################################################

  describe "Index" do
    setup [:create_profile, :register_and_log_in_user, :make_user_admin]

    @tag :profile_liveview
    test "lists all profiles", %{conn: conn, user: user} do
      {:ok, _index_live, html} = live(conn, ~p"/profiles")

      assert html =~ "Listing Profiles"
      assert html =~ user.profile.username
    end

    @tag :profile_liveview
    @tag :gettext
    test "index texts are translated to the first language in 'accept-language'
  which match one of the locales defined for the application",
         %{conn: conn, profile: profile} do
      conn = conn |> set_language_to_de_then_fr()
      {:ok, _index_live, html} = live(conn, ~p"/profiles")

      assert html =~ "Référencement des profiles"
      assert html =~ profile.username
    end

    @tag :profile_liveview
    @tag :gettext
    test "index texts are not translated ('en' is the default locale) if none
  of the languages in 'accept-language' is part of the locales defined for
  the app",
         %{conn: conn, profile: profile} do
      conn = conn |> set_language_to_unknown()
      {:ok, _index_live, html} = live(conn, ~p"/profiles")

      assert html =~ "Listing Profiles"
      assert html =~ profile.username
    end

    @tag :profile_liveview
    test "updates profile in listing", %{conn: conn, profile: profile} do
      {:ok, index_live, _html} = live(conn, ~p"/profiles")

      assert index_live
             |> element("#profiles-#{profile.id} a", "Edit")
             |> render_click() =~
               "Edit Profile"

      assert_patch(index_live, ~p"/profiles/#{profile}/edit")

      assert index_live
             |> form("#profile-form", profile: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#profile-form", profile: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/profiles")

      html = render(index_live)
      assert html =~ "Profile updated successfully"
      assert html =~ "some updated username"
    end
  end

  @tag :profile_liveview
  describe "Show" do
    setup [:create_profile, :register_and_log_in_user, :make_user_admin]

    test "displays profile", %{conn: conn, user: user} do
      {:ok, _show_live, html} = live(conn, ~p"/profiles/#{user.id}")

      assert html =~ "Show Profile"
      assert html =~ user.profile.username
    end

    @tag :profile_liveview
    @tag :gettext
    test "show texts are translated to the first language in 'accept-language'
  which match one of the locales defined for the application",
         %{conn: conn, user: user} do
      conn = conn |> set_language_to_de_then_fr()
      {:ok, _index_live, html} = live(conn, ~p"/profiles/#{user.id}")

      assert html =~ "Afficher le profile"
      assert html =~ user.profile.username
    end

    @tag :profile_liveview
    @tag :gettext
    test "show texts are not translated ('en' is the default locale) if none
  of the languages in 'accept-language' is part of the locales defined for
  the app",
         %{conn: conn, user: user} do
      conn = conn |> set_language_to_unknown()
      {:ok, _index_live, html} = live(conn, ~p"/profiles/#{user.id}")

      assert html =~ "Show Profile"
      assert html =~ user.profile.username
    end

    @tag :profile_liveview
    test "updates profile within modal", %{conn: conn, user: user} do
      {:ok, show_live, _html} = live(conn, ~p"/profiles/#{user.id}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Profile"

      assert_patch(show_live, ~p"/profiles/#{user.id}/show/edit")

      assert show_live
             |> form("#profile-form", profile: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#profile-form", profile: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/profiles/#{user.id}")

      html = render(show_live)
      assert html =~ "Profile updated successfully"
      assert html =~ "some updated username"
    end
  end

  describe "Ownership Index" do
    setup [:create_profile, :register_and_log_in_user]

    @tag :profile_liveview
    test "list all ownerships for a profile if {id} = current_user.id",
         %{conn: conn, user: user} do
      id = user.id
      _profile_username = Profiles.get_profile!(id).username

      private_ownership = ownership_fixture(id)
      public_ownership = ownership_fixture(id, %{public: true})

      third_ownership =
        ownership_fixture(profile_fixture().id)

      {:ok, _index_live, html} =
        live(conn, ~p"/profiles/ownerships/by_profile/#{id}")

      assert html =~ "Listing your Ownerships"
      assert html =~ "ownerships/#{private_ownership.id}"
      assert html =~ "ownerships/#{public_ownership.id}"
      refute html =~ "ownerships/#{third_ownership.id}"
    end

    @tag :profile_liveview
    test "list all ownerships for a profile if current_user.role == :admin",
         %{conn: conn, user: user} do
      make_user_admin(%{user: user})

      third_profile = profile_fixture()
      id = third_profile.id

      third_private_ownership = ownership_fixture(id)
      third_public_ownership = ownership_fixture(id, %{public: true})

      {:ok, _index_live, html} =
        live(conn, ~p"/profiles/ownerships/by_profile/#{id}")

      assert html =~
               "Listing #{third_profile.username} Ownerships (admin view)"

      assert html =~ "ownerships/#{third_private_ownership.id}"
      assert html =~ "ownerships/#{third_public_ownership.id}"
    end

    @tag :profile_liveview
    test "list only public ownerships for a profile if {id} != current_user.id",
         %{conn: conn, profile: profile} do
      id = profile.id
      profile_username = profile.username

      private_ownership = ownership_fixture(id)
      public_ownership = ownership_fixture(id, %{public: true})

      third_ownership =
        ownership_fixture(profile_fixture().id, ownership_valid_attrs())

      {:ok, _index_live, html} =
        live(conn, ~p"/profiles/ownerships/by_profile/#{id}")

      assert html =~ "Listing #{profile_username} public Ownerships"
      refute html =~ "ownerships/#{private_ownership.id}"
      assert html =~ "ownerships/#{public_ownership.id}"
      refute html =~ "ownerships/#{third_ownership.id}"
    end
  end
end
