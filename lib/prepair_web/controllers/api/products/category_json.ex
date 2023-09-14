defmodule PrepairWeb.Api.Products.CategoryJSON do
  alias Prepair.Products.Category

  @doc """
  Renders a list of categories.
  """
  def index(%{categories: categories}) do
    %{data: for(category <- categories, do: data(category))}
  end

  @doc """
  Renders a single category.
  """
  def show(%{category: category}) do
    %{data: data(category)}
  end

  defp data(%Category{} = category) do
    %{
      id: category.id,
      average_lifetime_m: category.average_lifetime_m,
      description: category.description,
      image: category.image,
      name: category.name
    }
  end
end
