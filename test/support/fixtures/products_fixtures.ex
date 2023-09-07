defmodule Prepair.ProductsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Prepair.Products` context.
  """

  alias Prepair.Repo

  @doc """
  Generate a unique manufacturer name.
  """
  def unique_manufacturer_name,
    do: "some name#{System.unique_integer([:positive])}"

  @doc """
  Generate a manufacturer.
  """
  def manufacturer_fixture(attrs \\ %{}) do
    {:ok, manufacturer} =
      attrs
      |> Enum.into(manufacturer_valid_attrs())
      |> Prepair.Products.create_manufacturer()

    manufacturer
  end

  def manufacturer_valid_attrs() do
    %{
      description: "some description",
      image: "some image",
      name: unique_manufacturer_name()
    }
  end

  @doc """
  Generate a unique category name.
  """
  def unique_category_name, do: "some name#{System.unique_integer([:positive])}"

  @doc """
  Generate a category.
  """
  def category_fixture(attrs \\ %{}) do
    {:ok, category} =
      attrs
      |> Enum.into(category_valid_attrs())
      |> Prepair.Products.create_category()

    category
  end

  def category_valid_attrs() do
    %{
      average_lifetime_m: 42,
      description: "some description",
      image: "some image",
      name: unique_category_name()
    }
  end

  @doc """
  Generate a unique product reference.
  """
  def unique_product_reference,
    do: "some reference#{System.unique_integer([:positive])}"

  @doc """
  Generate a product.
  """
  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(product_valid_attrs())
      |> Prepair.Products.create_product()

    product
    |> Repo.preload([:category, :manufacturer, :parts])
  end

  def product_valid_attrs() do
    category = category_fixture()
    manufacturer = manufacturer_fixture()

    %{
      category_id: category.id,
      manufacturer_id: manufacturer.id,
      average_lifetime_m: 42,
      country_of_origin: "some country_of_origin",
      description: "some description",
      end_of_production: ~D[2023-07-11],
      image: "some image",
      name: "some name",
      reference: unique_product_reference(),
      start_of_production: ~D[2023-07-11]
    }
  end

  @doc """
  Generate a unique part reference.
  """
  def unique_part_reference,
    do: "some reference#{System.unique_integer([:positive])}"

  @doc """
  Generate a part.
  """
  def part_fixture(attrs \\ %{}) do
    {:ok, part} =
      attrs
      |> Enum.into(part_valid_attrs())
      |> Prepair.Products.create_part()

    part
    |> Repo.preload([:category, :manufacturer, :products])
  end

  def part_valid_attrs() do
    category = category_fixture()
    manufacturer = manufacturer_fixture()

    %{
      category_id: category.id,
      manufacturer_id: manufacturer.id,
      average_lifetime_m: 42,
      country_of_origin: "some country_of_origin",
      description: "some description",
      end_of_production: ~D[2023-07-11],
      image: "some image",
      main_material: "some main_material",
      name: "some name",
      reference: unique_part_reference(),
      start_of_production: ~D[2023-07-11]
    }
  end
end
