defmodule Prepair.ProductFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Prepair.Products` context.
  """

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
      |> Enum.into(%{
        description: "some description",
        image: "some image",
        name: unique_manufacturer_name()
      })
      |> Prepair.Products.create_manufacturer()

    manufacturer
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
      |> Enum.into(%{
        average_lifetime_m: 42,
        description: "some description",
        image: "some image",
        name: unique_category_name()
      })
      |> Prepair.Products.create_category()

    category
  end
end
