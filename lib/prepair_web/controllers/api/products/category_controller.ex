defmodule PrepairWeb.Api.Products.CategoryController do
  use PrepairWeb, :controller

  alias Prepair.Products
  alias Prepair.Products.Category

  action_fallback PrepairWeb.Api.FallbackController

  def index(conn, _params) do
    categories = Products.list_categories()
    render(conn, :index, categories: categories)
  end

  def create(conn, %{"category" => category_params}) do
    with {:ok, %Category{} = category} <-
           Products.create_category(category_params) do
      conn
      |> put_status(:created)
      |> put_resp_header(
        "location",
        ~p"/api/v1/products/categories/#{category}"
      )
      |> render(:show, category: category)
    end
  end

  def show(conn, %{"id" => id}) do
    category = Products.get_category!(id)
    render(conn, :show, category: category)
  end

  def show_category_from_product(conn, %{"id" => id}) do
    category = Products.get_category_from_product!(id)
    render(conn, :show, category: category)
  end

  def update(conn, %{"id" => id, "category" => category_params}) do
    category = Products.get_category!(id)

    # Trick to avoid empty fields returned by FlutterFlow when value isn't changed.
    category_params =
      Map.filter(category_params, fn {_key, val} -> val != "" end)

    with {:ok, %Category{} = category} <-
           Products.update_category(category, category_params) do
      render(conn, :show, category: category)
    end
  end

  def delete(conn, %{"id" => id}) do
    category = Products.get_category!(id)

    with {:ok, %Category{}} <-
           Products.delete_category(category) do
      send_resp(conn, :no_content, "")
    end
  end
end
