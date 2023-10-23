defmodule PrepairWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use PrepairWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  import Plug.Conn

  alias Prepair.Auth
  alias Prepair.Auth.ApiKey

  using do
    quote do
      # The default endpoint for testing
      @endpoint PrepairWeb.Endpoint

      use PrepairWeb, :verified_routes

      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest, except: [recycle: 1]
      import PrepairWeb.ConnCase
    end
  end

  setup tags do
    Prepair.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  @doc """
  Recycles the connection.

  This redefines `recycle/1` from `Phoenix.ConnTest` with different defaults, so
  that the `x-api-key` header is preserved accross requests in tests.
  """
  def recycle(conn) do
    Phoenix.ConnTest.recycle(
      conn,
      ~w(accept accept-language x-api-key authorization)
    )
  end

  @doc """
  Setup helper to create an API key and set the proper header.

      setup :create_and_set_api_key
  """
  def create_and_set_api_key(%{conn: conn}) do
    {:ok, %ApiKey{key: key}} = Auth.create_api_key("Test")
    %{conn: put_req_header(conn, "x-api-key", key)}
  end

  @doc """
  Setup helper that registers and logs in users.

      setup :register_and_log_in_user

  It stores an updated connection and a registered user in the
  test context.
  """
  def register_and_log_in_user(%{conn: conn}) do
    user = Prepair.AccountsFixtures.user_fixture()
    %{conn: log_in_user(conn, user), user: user}
  end

  @doc """
  Logs the given `user` into the `conn`.

  It returns an updated `conn`.
  """
  def log_in_user(conn, user) do
    token = Prepair.Accounts.generate_user_session_token(user)

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> put_session(:user_token, token)
    |> put_req_header("authorization", "Bearer #{Base.encode64(token)}")
  end
end
