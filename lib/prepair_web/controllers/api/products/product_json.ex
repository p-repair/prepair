defmodule PrepairWeb.Api.Products.ProductJSON do
  alias PrepairWeb.Api.Products.{CategoryJSON, ManufacturerJSON}
  alias Prepair.LegacyContexts.Products.Product
  alias Prepair.AshDomains.Products.Product, as: AshProduct
  alias Prepair.Repo

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

  def data(%Product{} = product) do
    product = Repo.preload(product, [:category, :manufacturer])

    %{
      id: product.id,
      category: CategoryJSON.data(product.category),
      manufacturer: ManufacturerJSON.data(product.manufacturer),
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

  # NOTE: Need this to pass tests with the fixture now using Ash
  def data(%AshProduct{} = product) do
    product = Ash.load!(product, [:category, :manufacturer])

    %{
      id: product.id,
      category: CategoryJSON.data(product.category),
      manufacturer: ManufacturerJSON.data(product.manufacturer),
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
