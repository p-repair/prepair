defmodule PrepairWeb.Api.Products.PartJSON do
  alias Prepair.Products.Part

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

  defp data(%Part{} = part) do
    %{
      id: part.id,
      category_id: part.category.id,
      category_name: part.category.name,
      manufacturer_id: part.manufacturer.id,
      manufacturer_name: part.manufacturer.name,
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
