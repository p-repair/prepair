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

  alias Prepair.Accounts
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
  Format data to be normalised JSON and pass asserts in tests.
  """
  def normalise_json(data) do
    data
    |> Jason.encode!()
    |> Jason.decode!()
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
    %{user: user, user_password: user_password} = create_user()
    %{conn: log_in_user(conn, user), user: user, user_password: user_password}
  end

  defp create_user() do
    user_password = Prepair.AccountsFixtures.valid_user_password()
    user = Prepair.AccountsFixtures.user_fixture(%{password: user_password})

    %{user: user, user_password: user_password}
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

  @doc """
  Makes the user admin.
  """
  def make_user_admin(%{user: user}) do
    {:ok, user} = Accounts.update_user_role(user, :admin)
    %{user: user}
  end

  @doc """
  Set accepted languages in the request headers of a conn.
  It is usefull to test gettext.
  """
  def set_language_to_de_then_fr(conn) do
    conn |> put_req_header("accept-language", "de-DE,fr-FR;q=0.8,en-US;q=0.5")
  end

  @doc """
  Set an unknown language in the request headers of a conn.
  It is usefull to test gettext
  """
  def set_language_to_unknown(conn) do
    conn |> put_req_header("accept-language", "unknown")
  end
end
