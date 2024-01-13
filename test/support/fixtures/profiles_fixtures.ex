defmodule Prepair.ProfilesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Prepair.Profiles` context.
  """

  alias Prepair.AccountsFixtures

  def unique_username, do: "User#{System.unique_integer()}"

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
end
