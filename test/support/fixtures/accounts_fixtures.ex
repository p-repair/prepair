defmodule Prepair.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Prepair.Accounts` context.
  """
  alias Prepair.ProfilesFixtures

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!#{System.unique_integer()}"

  def user_valid_attrs(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password()
    })
  end

  def user_fixture(u_attrs \\ %{}, p_attrs \\ %{}) do
    user_attrs = user_valid_attrs(u_attrs)
    profile_attrs = ProfilesFixtures.profile_valid_attrs(p_attrs)

    {:ok, user} = Prepair.Accounts.register_user(user_attrs, profile_attrs)
    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
