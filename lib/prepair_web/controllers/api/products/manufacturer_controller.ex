defmodule PrepairWeb.Api.Products.ManufacturerController do
  use PrepairWeb, :controller

  alias Prepair.Products
  alias Prepair.Products.Manufacturer

  action_fallback PrepairWeb.Api.FallbackController

  def index(conn, _params) do
    manufacturers = Products.list_manufacturers()
    render(conn, :index, manufacturers: manufacturers)
  end

  def create(conn, %{"manufacturer" => manufacturer_params}) do
    with {:ok, %Manufacturer{} = manufacturer} <-
           Products.create_manufacturer(manufacturer_params) do
      conn
      |> put_status(:created)
      |> put_resp_header(
        "location",
        ~p"/api/v1/products/manufacturers/#{manufacturer}"
      )
      |> render(:show, manufacturer: manufacturer)
    end
  end

  def show(conn, %{"id" => id}) do
    manufacturer = Products.get_manufacturer!(id)
    render(conn, :show, manufacturer: manufacturer)
  end

  def update(conn, %{"id" => id, "manufacturer" => manufacturer_params}) do
    manufacturer = Products.get_manufacturer!(id)

    # Trick to avoid empty fields returned by FlutterFlow when value isn't changed.
    manufacturer_params =
      Map.filter(manufacturer_params, fn {_key, val} -> val != "" end)

    with {:ok, %Manufacturer{} = manufacturer} <-
           Products.update_manufacturer(manufacturer, manufacturer_params) do
      render(conn, :show, manufacturer: manufacturer)
    end
  end

  def delete(conn, %{"id" => id}) do
    manufacturer = Products.get_manufacturer!(id)

    with {:ok, %Manufacturer{}} <-
           Products.delete_manufacturer(manufacturer) do
      send_resp(conn, :no_content, "")
    end
  end
end
