defmodule Prepair.LegacyContexts.ProfilesTest do
  use Prepair.DataCase

  alias Prepair.LegacyContexts.Profiles

  describe "profiles" do
    alias Prepair.LegacyContexts.Profiles.Profile

    import Prepair.LegacyContexts.ProfilesFixtures

    @invalid_attrs %{
      username: nil,
      consent: nil,
      newsletter: nil,
      people_in_household: nil
    }

    @random_id Ecto.UUID.generate()

    test "list_profiles/0 returns all profiles" do
      profile = profile_fixture()
      assert Profiles.list_profiles() == [profile]
    end

    test "get_profile!/1 returns the profile with given id" do
      profile = profile_fixture()
      assert Profiles.get_profile!(profile.id) == profile
    end

    test "get_profile!/1 raises if there is no profile with given id" do
      assert_raise Ecto.NoResultsError, fn ->
        Profiles.get_profile!(@random_id)
      end
    end

    test "create_profile/2 raises if the given id does not match a user" do
      assert_raise Ecto.ConstraintError, fn ->
        Profiles.create_profile(
          @random_id,
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
    alias Prepair.AshDomains.Profiles.Ownership

    import Prepair.LegacyContexts.ProfilesFixtures
    import Prepair.LegacyContexts.ProductsFixtures

    @invalid_attrs %{
      product_id: nil,
      public: nil,
      date_of_purchase: nil,
      warranty_duration_m: nil,
      price_of_purchase: nil
    }

    @tag :ownership_resource
    test "Ownership.list/0 returns all ownerships" do
      ownership = ownership_fixture()
      assert {:ok, [o]} = Ownership.list()
      assert o.id == ownership.id
    end

    @tag :ownership_resource
    test "Ownership.list_by_profile/1 returns only the profile public
    ownerships by default" do
      profile_id = profile_fixture().id

      _private_ownership = ownership_fixture(profile_id)

      public_ownership = ownership_fixture(profile_id, %{public: true})

      _third_ownership = ownership_fixture()

      assert {:ok, [_private_o, _public_o, _third_o]} = Ownership.list()

      assert {:ok, [public_o]} =
               Ownership.list_by_profile(%{profile_id: profile_id})

      assert public_o.id == public_ownership.id
    end

    @tag :ownership_resource
    test "Ownership.list_by_profile/1 returns all the profile ownerships when
    :include_private is set to true" do
      profile_id = profile_fixture().id

      private_ownership = ownership_fixture(profile_id)

      public_ownership = ownership_fixture(profile_id, %{public: true})

      _third_ownership = ownership_fixture()

      assert {:ok, [_private_o, _public_o, _third_o]} = Ownership.list()

      assert {:ok, [public_o, private_o]} =
               Ownership.list_by_profile(%{
                 profile_id: profile_id,
                 include_private: true
               })

      assert [public_o.id, private_o.id] ==
               [private_ownership.id, public_ownership.id]
    end

    @tag :ownership_resource
    test "Ownership.list_by_product/1 returns only the product public
    ownerships by default" do
      product_id = product_fixture().id

      _private_ownership =
        ownership_fixture(profile_fixture().id, %{product_id: product_id})

      public_ownership =
        ownership_fixture(profile_fixture().id, %{
          product_id: product_id,
          public: true
        })

      _third_ownership = ownership_fixture()

      assert {:ok, [_private_o, _public_o, _third_o]} = Ownership.list()

      assert {:ok, [public_o]} =
               Ownership.list_by_product(%{product_id: product_id})

      assert public_o.id == public_ownership.id
    end

    @tag :ownership_resource
    test "Ownership.list_by_product/1 returns all the product ownerships when
    :include_private is set to true" do
      product_id = product_fixture().id

      private_ownership =
        ownership_fixture(profile_fixture().id, %{product_id: product_id})

      public_ownership =
        ownership_fixture(profile_fixture().id, %{
          product_id: product_id,
          public: true
        })

      _third_ownership = ownership_fixture()

      assert {:ok, [_private_o, _public_o, _third_o]} = Ownership.list()

      assert {:ok, [pivate_o, public_o]} =
               Ownership.list_by_product(%{
                 product_id: product_id,
                 include_private: true
               })

      assert [pivate_o.id, public_o.id] == [
               private_ownership.id,
               public_ownership.id
             ]
    end

    @tag :ownership_resource
    test "Ownership.count_by_product/1 returns the ownership count for the given
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

      assert Ownership.list!() |> Enum.count() == 3
      assert Ownership.count_by_product(product_id) == 2
    end

    @tag :ownership_resource
    test "Ownership.get/1 returns the ownership with given id" do
      ownership = ownership_fixture()
      assert {:ok, o} = Ownership.get(ownership.id)
      assert o.id == ownership.id
    end

    @tag :ownership_resource
    test "Ownership.create/2 with valid data creates an ownership" do
      assert {:ok, %Ownership{} = ownership} =
               Ownership.create(
                 profile_id(),
                 ownership_valid_attrs()
               )

      assert ownership.public == false
      assert ownership.date_of_purchase == ~D[2024-01-14]
      assert ownership.warranty_duration_m == 24
      assert ownership.price_of_purchase == 400
    end

    @tag :ownership_resource
    test "Ownership.create/2 with invalid data returns error changeset" do
      assert {:error, %Ash.Error.Invalid{}} =
               Ownership.create(profile_id(), @invalid_attrs)
    end

    @tag :ownership_resource
    test "Ownership.update/2 with valid data updates the ownership" do
      ownership = ownership_fixture()

      update_attrs = %{
        public: true,
        date_of_purchase: ~D[2024-01-15],
        warranty_duration_m: 43,
        price_of_purchase: 43
      }

      assert {:ok, %Ownership{} = ownership} =
               Ownership.update(ownership, update_attrs)

      assert ownership.public == true
      assert ownership.date_of_purchase == ~D[2024-01-15]
      assert ownership.warranty_duration_m == 43
      assert ownership.price_of_purchase == 43
    end

    @tag :ownership_resource
    test "Ownership.update/2 with invalid data returns error changeset" do
      ownership = ownership_fixture()

      assert {:error, %Ash.Error.Invalid{}} =
               Ownership.update(ownership, @invalid_attrs)

      assert ownership.date_of_purchase ==
               Ownership.get!(ownership.id).date_of_purchase
    end

    @tag :ownership_resource
    test "Ownership.delete/1 deletes the ownership" do
      ownership = ownership_fixture()
      assert :ok == Ownership.delete(ownership)

      assert_raise Ash.Error.Query.NotFound, fn ->
        Ownership.get!(ownership.id)
      end
    end

    # NOTE: Do we need to create a code_interface like Ownership.change?
    @tag :ownership_resource
    test "Ash.Changeset.new(ownership) returns an ownership changeset" do
      ownership = ownership_fixture()
      assert %Ash.Changeset{} = Ash.Changeset.new(ownership)
    end
  end
end
