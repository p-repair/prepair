defmodule Prepair.LegacyContexts.Auth do
  @moduledoc """
  Context for authentication-related data.
  """

  import Ecto.Query, warn: false

  alias Ecto.Changeset
  alias Prepair.Repo
  alias Prepair.LegacyContexts.Auth.ApiKey

  @doc """
  Returns the list of API keys by their name.

  ## Examples

      iex> list_api_keys()
      ["Some API key", ...]

  """
  def list_api_keys() do
    ApiKey |> Repo.all() |> Enum.map(& &1.name)
  end

  @doc """
  Creates an API key.

  ## Examples

      iex> create_api_key("Some name")
      {:ok, %ApiKey{}}

      iex> create_api_key("Already taken name")
      {:error, %Ecto.Changeset{}}

  """
  @spec create_api_key(String.t()) ::
          {:ok, ApiKey.t()} | {:error, Changeset.t()}
  def create_api_key(name) when is_binary(name) do
    %ApiKey{name: name, key: generate_api_key()}
    |> ApiKey.changeset(%{})
    |> Repo.insert()
  end

  @doc """
  Gets the status of an API key.

  This function returns:

  * `:valid` when the API key is valid,
  * `:revoked` when the API key has been revoked,
  * `:not_found` when the API key is unknown.

  ## Examples

      iex> get_api_key_status("s7b9B2f9JPocGn1qfd4qv4yYxETkWQmB3zx3voKXLjs=")
      :valid
  """
  @spec get_api_key_status(String.t()) :: :valid | :revoked | :not_found
  def get_api_key_status(key) when is_binary(key) do
    case Repo.get_by(ApiKey, key: key) do
      nil -> :not_found
      %ApiKey{revoked_at: nil} -> :valid
      %ApiKey{revoked_at: _} -> :revoked
    end
  end

  @doc """
  Revokes an API key.

  ## Examples

      iex> revoke_api_key!("An API key")
      :ok
  """
  @spec revoke_api_key!(String.t()) :: :ok
  def revoke_api_key!(name) when is_binary(name) do
    ApiKey
    |> Repo.get_by!(name: name)
    |> ApiKey.changeset(%{revoked_at: DateTime.utc_now()})
    |> Repo.update!()

    :ok
  end

  ############################################################################
  ##                                Helpers                                 ##
  ############################################################################

  # Generates an API key.
  @spec generate_api_key() :: String.t()
  defp generate_api_key() do
    :crypto.strong_rand_bytes(32) |> Base.encode64()
  end
end
