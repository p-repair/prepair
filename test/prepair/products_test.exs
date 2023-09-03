defmodule Prepair.ProductsTest do
  use Prepair.DataCase

  alias Prepair.Products

  describe "manufacturers" do
    alias Prepair.Products.Manufacturer

    import Prepair.ProductsFixtures

    @invalid_attrs %{description: nil, image: nil, name: nil}

    test "list_manufacturers/0 returns all manufacturers" do
      manufacturer = manufacturer_fixture()
      assert Products.list_manufacturers() == [manufacturer]
    end

    test "get_manufacturer!/1 returns the manufacturer with given id" do
      manufacturer = manufacturer_fixture()
      assert Products.get_manufacturer!(manufacturer.id) == manufacturer
    end

    test "create_manufacturer/1 with valid data creates a manufacturer" do
      valid_attrs = %{
        description: "some description",
        image: "some image",
        name: "some name"
      }

      assert {:ok, %Manufacturer{} = manufacturer} =
               Products.create_manufacturer(valid_attrs)

      assert manufacturer.description == "some description"
      assert manufacturer.image == "some image"
      assert manufacturer.name == "some name"
    end

    test "create_manufacturer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Products.create_manufacturer(@invalid_attrs)
    end

    test "update_manufacturer/2 with valid data updates the manufacturer" do
      manufacturer = manufacturer_fixture()

      update_attrs = %{
        description: "some updated description",
        image: "some updated image",
        name: "some updated name"
      }

      assert {:ok, %Manufacturer{} = manufacturer} =
               Products.update_manufacturer(manufacturer, update_attrs)

      assert manufacturer.description == "some updated description"
      assert manufacturer.image == "some updated image"
      assert manufacturer.name == "some updated name"
    end

    test "update_manufacturer/2 with invalid data returns error changeset" do
      manufacturer = manufacturer_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Products.update_manufacturer(manufacturer, @invalid_attrs)

      assert manufacturer == Products.get_manufacturer!(manufacturer.id)
    end

    test "delete_manufacturer/1 deletes the manufacturer" do
      manufacturer = manufacturer_fixture()
      assert {:ok, %Manufacturer{}} = Products.delete_manufacturer(manufacturer)

      assert_raise Ecto.NoResultsError, fn ->
        Products.get_manufacturer!(manufacturer.id)
      end
    end

    test "change_manufacturer/1 returns a manufacturer changeset" do
      manufacturer = manufacturer_fixture()
      assert %Ecto.Changeset{} = Products.change_manufacturer(manufacturer)
    end
  end

  describe "categories" do
    alias Prepair.Products.Category

    import Prepair.ProductsFixtures

    @invalid_attrs %{
      average_lifetime_m: nil,
      description: nil,
      image: nil,
      name: nil
    }

    test "list_categories/0 returns all categories" do
      category = category_fixture()
      assert Products.list_categories() == [category]
    end

    test "get_category!/1 returns the category with given id" do
      category = category_fixture()
      assert Products.get_category!(category.id) == category
    end

    test "create_category/1 with valid data creates a category" do
      valid_attrs = %{
        average_lifetime_m: 42,
        description: "some description",
        image: "some image",
        name: "some name"
      }

      assert {:ok, %Category{} = category} =
               Products.create_category(valid_attrs)

      assert category.average_lifetime_m == 42
      assert category.description == "some description"
      assert category.image == "some image"
      assert category.name == "some name"
    end

    test "create_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Products.create_category(@invalid_attrs)
    end

    test "update_category/2 with valid data updates the category" do
      category = category_fixture()

      update_attrs = %{
        average_lifetime_m: 43,
        description: "some updated description",
        image: "some updated image",
        name: "some updated name"
      }

      assert {:ok, %Category{} = category} =
               Products.update_category(category, update_attrs)

      assert category.average_lifetime_m == 43
      assert category.description == "some updated description"
      assert category.image == "some updated image"
      assert category.name == "some updated name"
    end

    test "update_category/2 with invalid data returns error changeset" do
      category = category_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Products.update_category(category, @invalid_attrs)

      assert category == Products.get_category!(category.id)
    end

    test "delete_category/1 deletes the category" do
      category = category_fixture()
      assert {:ok, %Category{}} = Products.delete_category(category)

      assert_raise Ecto.NoResultsError, fn ->
        Products.get_category!(category.id)
      end
    end

    test "change_category/1 returns a category changeset" do
      category = category_fixture()
      assert %Ecto.Changeset{} = Products.change_category(category)
    end
  end

  describe "products" do
    alias Prepair.Products.Product

    import Prepair.ProductsFixtures

    @invalid_attrs %{
      average_lifetime_m: nil,
      country_of_origin: nil,
      description: nil,
      end_of_production: nil,
      image: nil,
      name: nil,
      reference: nil,
      start_of_production: nil
    }

    test "list_products/0 returns all products" do
      # Unload fields [:category, :manufacturer, :parts] to be aligned with
      # list_products() where they are not preloaded.
      product =
        product_fixture()
        |> unload(:category)
        |> unload(:manufacturer)
        |> unload(:parts, :many)

      assert Products.list_products() == [product]
    end

    test "get_product!/1 returns the product with given id" do
      product = product_fixture()
      assert Products.get_product!(product.id) == product
    end

    test "create_product/1 with valid data creates a product" do
      category = category_fixture()
      manufacturer = manufacturer_fixture()

      valid_attrs = %{
        category_id: category.id,
        manufacturer_id: manufacturer.id,
        average_lifetime_m: 42,
        country_of_origin: "some country_of_origin",
        description: "some description",
        end_of_production: ~D[2023-07-11],
        image: "some image",
        name: "some name",
        reference: "some reference",
        start_of_production: ~D[2023-07-11]
      }

      assert {:ok, %Product{} = product} = Products.create_product(valid_attrs)
      assert product.average_lifetime_m == 42
      assert product.country_of_origin == "some country_of_origin"
      assert product.description == "some description"
      assert product.end_of_production == ~D[2023-07-11]
      assert product.image == "some image"
      assert product.name == "some name"
      assert product.reference == "some reference"
      assert product.start_of_production == ~D[2023-07-11]
    end

    test "create_product/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Products.create_product(@invalid_attrs)
    end

    test "update_product/2 with valid data updates the product" do
      product = product_fixture()

      update_attrs = %{
        average_lifetime_m: 43,
        country_of_origin: "some updated country_of_origin",
        description: "some updated description",
        end_of_production: ~D[2023-07-12],
        image: "some updated image",
        name: "some updated name",
        reference: "some updated reference",
        start_of_production: ~D[2023-07-12]
      }

      assert {:ok, %Product{} = product} =
               Products.update_product(product, update_attrs)

      assert product.average_lifetime_m == 43
      assert product.country_of_origin == "some updated country_of_origin"
      assert product.description == "some updated description"
      assert product.end_of_production == ~D[2023-07-12]
      assert product.image == "some updated image"
      assert product.name == "some updated name"
      assert product.reference == "some updated reference"
      assert product.start_of_production == ~D[2023-07-12]
    end

    test "update_product/2 with invalid data returns error changeset" do
      product = product_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Products.update_product(product, @invalid_attrs)

      assert product == Products.get_product!(product.id)
    end

    test "delete_product/1 deletes the product" do
      product = product_fixture()
      assert {:ok, %Product{}} = Products.delete_product(product)

      assert_raise Ecto.NoResultsError, fn ->
        Products.get_product!(product.id)
      end
    end

    test "change_product/1 returns a product changeset" do
      product = product_fixture()
      assert %Ecto.Changeset{} = Products.change_product(product)
    end
  end

  describe "parts" do
    alias Prepair.Products.Part

    import Prepair.ProductsFixtures

    @invalid_attrs %{
      average_lifetime_m: nil,
      country_of_origin: nil,
      description: nil,
      end_of_production: nil,
      image: nil,
      main_material: nil,
      name: nil,
      reference: nil,
      start_of_production: nil
    }

    test "list_parts/0 returns all parts" do
      # Unload field :products to be aligned with list_parts() where they are
      # not preloaded.
      part =
        part_fixture()
        |> unload(:category)
        |> unload(:manufacturer)
        |> unload(:products, :many)

      assert Products.list_parts() == [part]
    end

    test "get_part!/1 returns the part with given id" do
      part = part_fixture()
      assert Products.get_part!(part.id) == part
    end

    test "create_part/1 with valid data creates a part" do
      manufacturer = manufacturer_fixture()

      valid_attrs = %{
        manufacturer_id: manufacturer.id,
        average_lifetime_m: 42,
        country_of_origin: "some country_of_origin",
        description: "some description",
        end_of_production: ~D[2023-07-11],
        image: "some image",
        main_material: "some main_material",
        name: "some name",
        reference: "some reference",
        start_of_production: ~D[2023-07-11]
      }

      assert {:ok, %Part{} = part} = Products.create_part(valid_attrs)
      assert part.average_lifetime_m == 42
      assert part.country_of_origin == "some country_of_origin"
      assert part.description == "some description"
      assert part.end_of_production == ~D[2023-07-11]
      assert part.image == "some image"
      assert part.main_material == "some main_material"
      assert part.name == "some name"
      assert part.reference == "some reference"
      assert part.start_of_production == ~D[2023-07-11]
    end

    test "create_part/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Products.create_part(@invalid_attrs)
    end

    test "update_part/2 with valid data updates the part" do
      part = part_fixture()

      update_attrs = %{
        average_lifetime_m: 43,
        country_of_origin: "some updated country_of_origin",
        description: "some updated description",
        end_of_production: ~D[2023-07-12],
        image: "some updated image",
        main_material: "some updated main_material",
        name: "some updated name",
        reference: "some updated reference",
        start_of_production: ~D[2023-07-12]
      }

      assert {:ok, %Part{} = part} = Products.update_part(part, update_attrs)
      assert part.average_lifetime_m == 43
      assert part.country_of_origin == "some updated country_of_origin"
      assert part.description == "some updated description"
      assert part.end_of_production == ~D[2023-07-12]
      assert part.image == "some updated image"
      assert part.main_material == "some updated main_material"
      assert part.name == "some updated name"
      assert part.reference == "some updated reference"
      assert part.start_of_production == ~D[2023-07-12]
    end

    test "update_part/2 with invalid data returns error changeset" do
      part = part_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Products.update_part(part, @invalid_attrs)

      assert part == Products.get_part!(part.id)
    end

    test "delete_part/1 deletes the part" do
      part = part_fixture()
      assert {:ok, %Part{}} = Products.delete_part(part)
      assert_raise Ecto.NoResultsError, fn -> Products.get_part!(part.id) end
    end

    test "change_part/1 returns a part changeset" do
      part = part_fixture()
      assert %Ecto.Changeset{} = Products.change_part(part)
    end
  end
end
