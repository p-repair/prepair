defmodule Prepair.ProfilesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Prepair.Profiles` context.
  """

  alias Prepair.AccountsFixtures
  alias Prepair.ProductsFixtures

  def unique_username, do: "User#{System.unique_integer()}"

  @doc """
  Arbitrary defined valid attributes for a profile.
  """
  def profile_valid_attrs(attrs \\ %{}) do
    Enum.into(attrs, %{
      username: unique_username(),
      newsletter: false,
      people_in_household: 1
    })
  end

  @doc """
  Generate a profile.
  """
  def profile_fixture() do
    user = AccountsFixtures.user_fixture()
    user.profile
  end

  @doc """
  Arbitrary defined valid attributes for an ownership.
  """
  def profile_uuid(), do: profile_fixture().uuid

  def ownership_valid_attrs() do
    product = ProductsFixtures.product_fixture()

    %{
      product_uuid: product.uuid,
      date_of_purchase: ~D[2024-01-14],
      warranty_duration_m: 24,
      price_of_purchase: 400,
      public: false
    }
  end

  @doc """
  Generate an ownership.
  """
  def ownership_fixture(profile_uuid \\ profile_uuid(), attrs \\ %{}) do
    attrs = attrs |> Enum.into(ownership_valid_attrs())
    {:ok, ownership} = Prepair.Profiles.create_ownership(profile_uuid, attrs)

    ownership
  end
end
