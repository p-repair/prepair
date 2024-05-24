defmodule PrepairWeb.Api.Products.CategoryJSON do
  alias Prepair.LegacyContexts.Products.Category

  alias Prepair.AshDomains.Products.Category, as: AshCategory

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

  def data(%Category{} = category) do
    %{
      id: category.id,
      average_lifetime_m: category.average_lifetime_m,
      description: category.description,
      image: category.image,
      name: category.name
    }
  end

  # NOTE: Need this to pass tests with the fixture now using Ash
  def data(%AshCategory{} = category) do
    %{
      id: category.id,
      average_lifetime_m: category.average_lifetime_m,
      description: category.description,
      image: category.image,
      name: category.name
    }
  end

  # This function clause is needed to fit the case part.category is nil.
  def data(nil) do
    nil
  end
end
