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
        {String.to_existing_atom(k), str_to_list(v)}
      end)

    products = Products.list_products(filters)

    render(conn, :index, products: products)
  end

  def create(conn, %{"product" => product_params}) do
    params = product_params |> normalise_params()

    with {:ok, %Product{} = product} <-
           Products.create_product(params),
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
    params = product_params |> normalise_params()
    product = Products.get_product!(id)

    # Trick to avoid empty fields returned by FlutterFlow when value isn't changed.
    params =
      Map.filter(params, fn {_key, val} -> val != "" end)

    with {:ok, %Product{} = product} <-
           Products.update_product(product, params) do
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

  defp str_to_list("null") do
    []
  end

  defp str_to_list(str) do
    str
    |> String.split(~r/[\[\],\s]+/, trim: true)
  end
end
