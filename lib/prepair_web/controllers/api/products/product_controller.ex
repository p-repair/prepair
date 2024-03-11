defmodule PrepairWeb.Api.Products.ProductController do
  use PrepairWeb, :controller

  alias Prepair.Products
  alias Prepair.Products.Product
  alias Prepair.Repo

  action_fallback PrepairWeb.Api.FallbackController

  @index_filters ["product_ids", "category_id", "manufacturer_id"]

  def index(conn, params) do
    filters =
      params
      |> Map.filter(fn {k, _v} -> k in @index_filters end)
      |> Enum.map(fn {k, v} ->
        {String.to_existing_atom(k), str_to_int_list(v)}
      end)

    products = Products.list_products(filters)

    render(conn, :index, products: products)
  end

  # À modifier avec des filtres en query params
  def index_by_category_and_manufacturer(conn, %{
        "cat_id" => cat_id,
        "man_id" => man_id
      }) do
    products =
      Products.list_products_by_category_and_manufacturer_id(
        String.to_integer(cat_id),
        String.to_integer(man_id)
      )

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

  defp str_to_int_list("null") do
    []
  end

  defp str_to_int_list(str) do
    str
    |> String.split(~r/[\[\],\s]+/, trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end
