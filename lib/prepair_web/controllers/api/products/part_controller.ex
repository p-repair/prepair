defmodule PrepairWeb.Api.Products.PartController do
  use PrepairWeb, :controller

  alias Prepair.Products
  alias Prepair.Products.Part
  alias Prepair.Repo

  action_fallback PrepairWeb.Api.FallbackController

  def index(conn, _params) do
    parts = Products.list_parts()
    render(conn, :index, parts: parts)
  end

  def create(conn, %{"part" => part_params}) do
    with {:ok, %Part{} = part} <-
           Products.create_part(part_params),
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
    part = Products.get_part!(id)

    # Trick to avoid empty fields returned by FlutterFlow when value isn't changed.
    part_params =
      Map.filter(part_params, fn {_key, val} -> val != "" end)

    with {:ok, %Part{} = part} <-
           Products.update_part(part, part_params) do
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
end
