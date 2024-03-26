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
    params = category_params |> normalise_params()

    with {:ok, %Category{} = category} <-
           Products.create_category(params) do
      conn
      |> put_status(:created)
      |> put_resp_header(
        "location",
        ~p"/api/v1/products/categories/#{category}"
      )
      |> render(:show, category: category)
    end
  end

  def show(conn, %{"uuid" => uuid}) do
    category = Products.get_category!(uuid)
    render(conn, :show, category: category)
  end

  def update(conn, %{"uuid" => uuid, "category" => category_params}) do
    params = category_params |> normalise_params()
    category = Products.get_category!(uuid)

    # Trick to avoid empty fields returned by FlutterFlow when value isn't changed.
    params =
      Map.filter(params, fn {_key, val} -> val != "" end)

    with {:ok, %Category{} = category} <-
           Products.update_category(category, params) do
      render(conn, :show, category: category)
    end
  end

  def delete(conn, %{"uuid" => uuid}) do
    category = Products.get_category!(uuid)

    with {:ok, %Category{}} <-
           Products.delete_category(category) do
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
