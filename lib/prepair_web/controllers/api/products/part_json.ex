defmodule PrepairWeb.Api.Products.PartJSON do
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

  defp data(%Part{} = part) do
    part = Repo.preload(part, [:category, :manufacturer])

    %{
      id: part.id,
      category_id: category_id(part.category),
      category_name: category_name(part.category),
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

  defp category_id(nil), do: nil
  defp category_id(category), do: category.id

  defp category_name(nil), do: nil
  defp category_name(category), do: category.name
end