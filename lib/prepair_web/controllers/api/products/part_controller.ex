defmodule PrepairWeb.Api.Products.PartController do
  use PrepairWeb, :controller

  alias Prepair.LegacyContexts.Products
  alias Prepair.LegacyContexts.Products.Part
  alias Prepair.Repo

  action_fallback PrepairWeb.Api.FallbackController

  def index(conn, _params) do
    parts = Products.list_parts()
    render(conn, :index, parts: parts)
  end

  def create(conn, %{"part" => part_params}) do
    params = part_params |> normalise_params()

    with {:ok, %Part{} = part} <-
           Products.create_part(params),
         part <-
           Repo.preload(part, [:category, :manufacturer]) do
      conn
      |> put_status(:created)
      |> put_resp_header(
        "location",
        ~p"/api/v1/products/parts/#{part}"
      )
      |> render(:show, part: part)
    end
  end

  def show(conn, %{"id" => id}) do
    part = Products.get_part!(id)
    render(conn, :show, part: part)
  end

  def update(conn, %{"id" => id, "part" => part_params}) do
    params = part_params |> normalise_params()
    part = Products.get_part!(id)

    # Trick to avoid empty fields returned by FlutterFlow when value isn't changed.
    params =
      Map.filter(params, fn {_key, val} -> val != "" end)

    with {:ok, %Part{} = part} <-
           Products.update_part(part, params) do
      render(conn, :show, part: part)
    end
  end

  def delete(conn, %{"id" => id}) do
    part = Products.get_part!(id)

    with {:ok, %Part{}} <-
           Products.delete_part(part) do
      send_resp(conn, :no_content, "")
    end
  end

  @doc """
  Helper function to transform string keys into atom keys before to pass
  them to the context functions.

  """
  def normalise_params(params) do
    params
    |> Map.to_list()
    |> Enum.reduce(%{}, fn {k, v}, acc ->
      Map.put(acc, String.to_existing_atom(k), v)
    end)
  end
end
