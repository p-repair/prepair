defmodule PrepairWeb.Api.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use PrepairWeb, :controller

  ## Generic behaviour

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: PrepairWeb.Api.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(html: PrepairWeb.ErrorHTML, json: PrepairWeb.ErrorJSON)
    |> render(:"404")
  end

  ## Behaviour for session controller defined errors

  def call(conn, {:error, :invalid_credentials}) do
    conn
    |> put_status(:unauthorized)
    |> json(%{errors: [%{details: "Invalid username or password."}]})
  end

  def call(conn, {:error, :bad_request}) do
    conn
    |> put_status(:bad_request)
    |> json(%{errors: [%{details: "Bad request."}]})
  end
end
