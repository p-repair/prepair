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

  describe "ownerships" do
    alias Prepair.Profiles.Ownership

    import Prepair.ProfilesFixtures
    import Prepair.ProductsFixtures

    @invalid_attrs %{
      product_id: nil,
      public: nil,
      date_of_purchase: nil,
      warranty_duration_m: nil,
      price_of_purchase: nil
    }

    test "list_ownerships/0 returns all ownerships" do
      ownership = ownership_fixture()
      assert Profiles.list_ownerships() == [ownership]
    end

    test "list_ownerships_by_profile/2 returns only the profile public
    ownerships by default" do
      profile_id = profile_fixture().id

      private_ownership = ownership_fixture(profile_id)

      public_ownership = ownership_fixture(profile_id, %{public: true})

      third_ownership = ownership_fixture()

      assert Profiles.list_ownerships() ==
               [private_ownership, public_ownership, third_ownership]

      assert Profiles.list_ownerships_by_profile(profile_id) ==
               [public_ownership]
    end

    test "list_ownerships_by_profile/2 returns all the profile ownerships when
    :include_private is set to true" do
      profile_id = profile_fixture().id

      private_ownership = ownership_fixture(profile_id)

      public_ownership = ownership_fixture(profile_id, %{public: true})

      third_ownership = ownership_fixture()

      assert Profiles.list_ownerships() ==
               [private_ownership, public_ownership, third_ownership]

      assert Profiles.list_ownerships_by_profile(profile_id,
               include_private: true
             ) ==
               [private_ownership, public_ownership]
    end

    test "list_ownerships_by_product/2 returns only the product public
    ownerships by default" do
      product_id = product_fixture().id

      private_ownership =
        ownership_fixture(profile_fixture().id, %{product_id: product_id})

      public_ownership =
        ownership_fixture(profile_fixture().id, %{
          product_id: product_id,
          public: true
        })

      third_ownership = ownership_fixture()

      assert Profiles.list_ownerships() ==
               [private_ownership, public_ownership, third_ownership]

      assert Profiles.list_ownerships_by_product(product_id) ==
               [public_ownership]
    end

    test "list_ownerships_by_product/2 returns all the product ownerships when
    include_private: is set to true" do
      product_id = product_fixture().id

      private_ownership =
        ownership_fixture(profile_fixture().id, %{product_id: product_id})

      public_ownership =
        ownership_fixture(profile_fixture().id, %{
          product_id: product_id,
          public: true
        })

      third_ownership = ownership_fixture()

      assert Profiles.list_ownerships() ==
               [private_ownership, public_ownership, third_ownership]

      assert Profiles.list_ownerships_by_product(product_id,
               include_private: true
             ) ==
               [private_ownership, public_ownership]
    end

    test "count_ownerships_by_product returns the ownership count for the given
    product" do
      product_id = product_fixture().id

      _private_ownership =
        ownership_fixture(profile_fixture().id, %{product_id: product_id})

      _public_ownership =
        ownership_fixture(profile_fixture().id, %{
          product_id: product_id,
          public: true
        })

      _third_ownership = ownership_fixture()

      assert Profiles.list_ownerships() |> Enum.count() == 3
      assert Profiles.count_ownerships_by_product(product_id) == 2
    end

    test "get_ownership!/1 returns the ownership with given id" do
      ownership = ownership_fixture()
      assert Profiles.get_ownership!(ownership.id) == ownership
    end

    test "create_ownership/2 with valid data creates an ownership" do
      assert {:ok, %Ownership{} = ownership} =
               Profiles.create_ownership(
                 profile_id(),
                 ownership_valid_attrs()
               )

      assert ownership.public == false
      assert ownership.date_of_purchase == ~D[2024-01-14]
      assert ownership.warranty_duration_m == 24
      assert ownership.price_of_purchase == 400
    end

    test "create_ownership/2 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Profiles.create_ownership(profile_id(), @invalid_attrs)
    end

    test "update_ownership/2 with valid data updates the ownership" do
      ownership = ownership_fixture()

      update_attrs = %{
        public: true,
        date_of_purchase: ~D[2024-01-15],
        warranty_duration_m: 43,
        price_of_purchase: 43
      }

      assert {:ok, %Ownership{} = ownership} =
               Profiles.update_ownership(ownership, update_attrs)

      assert ownership.public == true
      assert ownership.date_of_purchase == ~D[2024-01-15]
      assert ownership.warranty_duration_m == 43
      assert ownership.price_of_purchase == 43
    end

    test "update_ownership/2 with invalid data returns error changeset" do
      ownership = ownership_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Profiles.update_ownership(ownership, @invalid_attrs)

      assert ownership == Profiles.get_ownership!(ownership.id)
    end

    test "delete_ownership/1 deletes the ownership" do
      ownership = ownership_fixture()
      assert {:ok, %Ownership{}} = Profiles.delete_ownership(ownership)

      assert_raise Ecto.NoResultsError, fn ->
        Profiles.get_ownership!(ownership.id)
      end
    end

    test "change_ownership/1 returns an ownership changeset" do
      ownership = ownership_fixture()
      assert %Ecto.Changeset{} = Profiles.change_ownership(ownership)
    end
  end
end
