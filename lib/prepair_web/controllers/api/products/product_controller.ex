defmodule PrepairWeb.Api.Products.ProductController do
  use PrepairWeb, :controller

  alias Prepair.Products
  alias Prepair.Products.Product
  alias Prepair.Repo

  action_fallback PrepairWeb.Api.FallbackController

  def index(conn, _params) do
    products = Products.list_products()
    render(conn, :index, products: products)
  end

  def create(conn, %{"product" => product_params}) do
    with {:ok, %Product{} = product} <-
           Products.create_product(product_params),
         product <- Repo.preload(product, [:category, :manufacturer]) do
      conn
      |> put_status(:created)
      |> put_resp_header(
        "location",
        ~p"/api/v1/products/products/#{product}"
      )
      |> render(:show, product: product)
    end
  end

  def show(conn, %{"id" => id}) do
    product = Products.get_product!(id)
    render(conn, :show, product: product)
  end

  def update(conn, %{"id" => id, "product" => product_params}) do
    product = Products.get_product!(id)

    # Trick to avoid empty fields returned by FlutterFlow when value isn't changed.
    product_params =
      Map.filter(product_params, fn {_key, val} -> val != "" end)

    with {:ok, %Product{} = product} <-
           Products.update_product(product, product_params) do
      render(conn, :show, product: product)
    end
  end

  def delete(conn, %{"id" => id}) do
    product = Products.get_product!(id)

    with {:ok, %Product{}} <-
           Products.delete_product(product) do
      send_resp(conn, :no_content, "")
    end
  end
end
