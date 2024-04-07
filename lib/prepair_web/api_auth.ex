defmodule PrepairWeb.ApiAuth do
  @moduledoc """
  API authentication logic.
  """

  import Plug.Conn
  import Phoenix.Controller
  import PrepairWeb.Gettext

  alias Prepair.Auth

  @doc """
  Checks that a valid API key is present in the request.

  In case there is no valid API key, an error is returned.
  """
  def require_valid_api_key(conn, _opts) do
    with [api_key] <- get_req_header(conn, "x-api-key"),
         :valid <- Auth.get_api_key_status(api_key) do
      conn
    else
      _ ->
        conn
        |> put_status(:unauthorized)
        |> json(%{
          errors: [%{detail: dgettext("errors", "missing API key")}]
        })
        |> halt()
    end
  end
end
