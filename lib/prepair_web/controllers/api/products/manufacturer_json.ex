defmodule PrepairWeb.Api.Products.ManufacturerJSON do
  alias Prepair.LegacyContexts.Products.Manufacturer

  alias Prepair.AshDomains.Products.Manufacturer, as: AshManufacturer

  @doc """
  Renders a list of manufacturers.
  """
  def index(%{manufacturers: manufacturers}) do
    %{data: for(manufacturer <- manufacturers, do: data(manufacturer))}
  end

  @doc """
  Renders a single manufacturer.
  """
  def show(%{manufacturer: manufacturer}) do
    %{data: data(manufacturer)}
  end

  def data(%Manufacturer{} = manufacturer) do
    %{
      id: manufacturer.id,
      description: manufacturer.description,
      image: manufacturer.image,
      name: manufacturer.name
    }
  end

  # NOTE: Need this to pass tests with the fixture now using Ash
  def data(%AshManufacturer{} = manufacturer) do
    %{
      id: manufacturer.id,
      description: manufacturer.description,
      image: manufacturer.image,
      name: manufacturer.name
    }
  end
end
