defmodule PrepairWeb.ProfileLiveTest do
  use PrepairWeb.ConnCase

  alias Prepair.Profiles

  import Phoenix.LiveViewTest
  import Prepair.ProfilesFixtures

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

  describe "Index" do
    setup [:create_profile, :register_and_log_in_user]

    test "lists all profiles", %{conn: conn, profile: profile} do
      {:ok, _index_live, html} = live(conn, ~p"/profiles")

      assert html =~ "Listing Profiles"
      assert html =~ profile.username
    end

    test "updates profile in listing", %{conn: conn, profile: profile} do
      {:ok, index_live, _html} = live(conn, ~p"/profiles")

      assert index_live
             |> element("#profiles-#{profile.uuid} a", "Edit")
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

  describe "Show" do
    setup [:create_profile, :register_and_log_in_user]

    test "displays profile", %{conn: conn, profile: profile} do
      {:ok, _show_live, html} = live(conn, ~p"/profiles/#{profile}")

      assert html =~ "Show Profile"
      assert html =~ profile.username
    end

    test "updates profile within modal", %{conn: conn, profile: profile} do
      {:ok, show_live, _html} = live(conn, ~p"/profiles/#{profile}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Profile"

      assert_patch(show_live, ~p"/profiles/#{profile}/show/edit")

      assert show_live
             |> form("#profile-form", profile: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#profile-form", profile: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/profiles/#{profile}")

      html = render(show_live)
      assert html =~ "Profile updated successfully"
      assert html =~ "some updated username"
    end
  end

  describe "Ownership Index" do
    setup [:create_profile, :register_and_log_in_user]

    test "list all ownerships for a profile if {uuid} = current_user.uuid",
         %{conn: conn, user: user} do
      uuid = user.uuid
      _profile_username = Profiles.get_profile!(uuid).username

      private_ownership = ownership_fixture(uuid)
      public_ownership = ownership_fixture(uuid, %{public: true})

      third_ownership =
        ownership_fixture(profile_fixture().uuid)

      {:ok, _index_live, html} =
        live(conn, ~p"/profiles/ownerships/by_profile/#{uuid}")

      assert html =~ "Listing your Ownerships"
      assert html =~ "ownerships/#{private_ownership.uuid}"
      assert html =~ "ownerships/#{public_ownership.uuid}"
      refute html =~ "ownerships/#{third_ownership.uuid}"
    end

    test "list only public ownerships for a profile if {uuid} != current_user.uuid",
         %{conn: conn, profile: profile} do
      uuid = profile.uuid
      profile_username = profile.username

      private_ownership = ownership_fixture(uuid)
      public_ownership = ownership_fixture(uuid, %{public: true})

      third_ownership =
        ownership_fixture(profile_fixture().uuid, ownership_valid_attrs())

      {:ok, _index_live, html} =
        live(conn, ~p"/profiles/ownerships/by_profile/#{uuid}")

      assert html =~ "Listing #{profile_username} public Ownerships"
      refute html =~ "ownerships/#{private_ownership.uuid}"
      assert html =~ "ownerships/#{public_ownership.uuid}"
      refute html =~ "ownerships/#{third_ownership.uuid}"
    end
  end
end
