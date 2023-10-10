defmodule Prepair.AuthTest do
  alias Ecto.Changeset
  use Prepair.DataCase

  alias Prepair.Auth

  @name "Some API key"
  @unknown_key "SRICPND46x6YHN5Qs9hxEnoSoSvPZF/gggjvPRWzEnw="

  describe "api_keys" do
    alias Prepair.Auth.ApiKey

    test "list_api_keys/0 returns the name of existing API keys" do
      {:ok, api_key} = Auth.create_api_key(@name)
      assert Auth.list_api_keys() == [api_key.name]
    end

    test "create_api_key/1 creates an API key" do
      assert {:ok, %ApiKey{name: @name}} = Auth.create_api_key(@name)
    end

    test "create_api_key/1 generates a 256-bit API key encoded in Base64" do
      {:ok, %ApiKey{key: key}} = Auth.create_api_key(@name)

      assert {:ok, binary_key} = Base.decode64(key)
      assert byte_size(binary_key) == 32
    end

    test "create_api_key/1 with an empty name returns an error" do
      assert {:error, %Changeset{} = changeset} = Auth.create_api_key("")
      assert errors_on(changeset) == %{name: ["can't be blank"]}
    end

    test "create_api_key/1 with a nil name raises" do
      assert_raise FunctionClauseError, fn -> Auth.create_api_key(nil) end
    end

    test "create_api_key/1 returns an error if the name is already taken" do
      {:ok, %ApiKey{}} = Auth.create_api_key(@name)

      assert {:error, %Changeset{} = changeset} = Auth.create_api_key(@name)
      assert errors_on(changeset) == %{name: ["has already been taken"]}
    end

    test "get_api_key_status/1 returns :valid if the API key is valid" do
      {:ok, %ApiKey{key: key}} = Auth.create_api_key(@name)
      assert Auth.get_api_key_status(key) == :valid
    end

    test "get_api_key_status/1 returns :revoked if the API key has been revoked" do
      {:ok, %ApiKey{key: key}} = Auth.create_api_key(@name)
      Auth.revoke_api_key!(@name)
      assert Auth.get_api_key_status(key) == :revoked
    end

    test "get_api_key_status/1 returns :not_found if the API key does not exist" do
      assert Auth.get_api_key_status(@unknown_key) == :not_found
    end

    test "get_api_key_status/1 with a nil key raises" do
      assert_raise FunctionClauseError, fn -> Auth.get_api_key_status(nil) end
    end

    test "revoke_api_key!/1 revokes an API key" do
      {:ok, %ApiKey{}} = Auth.create_api_key(@name)
      assert :ok = Auth.revoke_api_key!(@name)
      assert %ApiKey{revoked_at: %DateTime{}} = Repo.get_by(ApiKey, name: @name)
    end

    test "revoke_api_key!/1 raises if the API key does not exist" do
      assert_raise Ecto.NoResultsError, fn -> Auth.revoke_api_key!(@name) end
    end
  end
end
