defmodule Prepair.ProfilesTest do
  use Prepair.DataCase

  alias Prepair.Profiles

  describe "profiles" do
    alias Prepair.Profiles.Profile

    import Prepair.ProfilesFixtures

    @invalid_attrs %{
      username: nil,
      consent: nil,
      newsletter: nil,
      people_in_household: nil
    }

    test "list_profiles/0 returns all profiles" do
      profile = profile_fixture()
      assert Profiles.list_profiles() == [profile]
    end

    test "get_profile!/1 returns the profile with given id" do
      profile = profile_fixture()
      assert Profiles.get_profile!(profile.id) == profile
    end

    test "get_profile!/1 raises if there is no profile with given id" do
      assert_raise Ecto.NoResultsError, fn -> Profiles.get_profile!(-1) end
    end

    test "create_profile/2 raises if the given id does not match a user" do
      assert_raise Ecto.ConstraintError, fn ->
        Profiles.create_profile(
          -1,
          profile_valid_attrs()
        )
      end
    end

    test "create_profile/2 raises if the given id is already created" do
      existing_id = profile_fixture().id

      assert_raise Ecto.ConstraintError, fn ->
        Profiles.create_profile(
          existing_id,
          profile_valid_attrs()
        )
      end
    end

    test "update_profile/2 with valid data updates the profile" do
      profile = profile_fixture()

      update_attrs = %{
        username: "some updated username",
        newsletter: true,
        people_in_household: 43
      }

      assert {:ok, %Profile{} = profile} =
               Profiles.update_profile(profile, update_attrs)

      assert profile.username == "some updated username"
      assert profile.newsletter == true
      assert profile.people_in_household == 43
    end

    test "update_profile/2 with invalid data returns error changeset" do
      profile = profile_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Profiles.update_profile(profile, @invalid_attrs)

      assert profile == Profiles.get_profile!(profile.id)
    end

    test "change_profile/1 returns a profile changeset" do
      profile = profile_fixture()
      assert %Ecto.Changeset{} = Profiles.change_profile(profile)
    end
  end
end
