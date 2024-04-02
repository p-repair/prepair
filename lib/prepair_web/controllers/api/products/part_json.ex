defmodule PrepairWeb.Api.Products.PartJSON do
  alias PrepairWeb.Api.Products.{CategoryJSON, ManufacturerJSON}
  alias Prepair.Products.Part
  alias Prepair.Repo

  @doc """
  Renders a list of parts.
  """
  def index(%{parts: parts}) do
    %{data: for(part <- parts, do: data(part))}
  end

  @doc """
  Renders a single part.
  """
  def show(%{part: part}) do
    %{data: data(part)}
  end

  def data(%Part{} = part) do
    part = Repo.preload(part, [:category, :manufacturer])

    %{
      uuid: part.uuid,
      category: CategoryJSON.data(part.category),
      manufacturer: ManufacturerJSON.data(part.manufacturer),
      name: part.name,
      reference: part.reference,
      description: part.description,
      image: part.image,
      average_lifetime_m: part.average_lifetime_m,
      country_of_origin: part.country_of_origin,
      start_of_production: part.start_of_production,
      end_of_production: part.end_of_production,
      main_material: part.main_material
    }
  end
end
