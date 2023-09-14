defmodule PrepairWeb.Api.Products.ProductJSON do
  alias Prepair.Products.Product

  @doc """
  Renders a list of products.
  """
  def index(%{products: products}) do
    %{data: for(product <- products, do: data(product))}
  end

  @doc """
  Renders a single product.
  """
  def show(%{product: product}) do
    %{data: data(product)}
  end

  defp data(%Product{} = product) do
    %{
      id: product.id,
      category_id: product.category.id,
      category_name: product.category.name,
      manufacturer_id: product.manufacturer.id,
      manufacturer_name: product.manufacturer.name,
      name: product.name,
      reference: product.reference,
      description: product.description,
      image: product.image,
      average_lifetime_m: product.average_lifetime_m,
      country_of_origin: product.country_of_origin,
      start_of_production: product.start_of_production,
      end_of_production: product.end_of_production
    }
  end
end
