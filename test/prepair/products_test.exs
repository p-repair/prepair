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
      valid_attrs = manufacturer_valid_attrs()

      assert {:ok, %Manufacturer{} = manufacturer} =
               Products.create_manufacturer(valid_attrs)

      assert manufacturer.description == valid_attrs.description
      assert manufacturer.image == valid_attrs.image
      assert manufacturer.name == valid_attrs.name
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
      valid_attrs = category_valid_attrs()

      assert {:ok, %Category{} = category} =
               Products.create_category(valid_attrs)

      assert category.average_lifetime_m == valid_attrs.average_lifetime_m
      assert category.description == valid_attrs.description
      assert category.image == valid_attrs.image
      assert category.name == valid_attrs.name
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

    # Unload fields [:category, :manufacturer, :parts] to be aligned with
    # fuctions tested below, such as list_products() where they are not
    # preloaded.
    defp unload_product_relations(product) do
      product
      |> unload(:category)
      |> unload(:manufacturer)
      |> unload(:parts, :many)
    end

    test "list_products/0 returns all products" do
      product = product_fixture() |> unload_product_relations()

      assert Products.list_products() == [product]
    end

    test "list_products_by_id/1 returns an empty list when none of [ids] exist" do
      assert Products.list_products_by_id([456, 457, 458]) == []
    end

    test "list_products_by_id/1 returns a list of products matching witch [ids]" do
      product_1 = product_fixture() |> unload_product_relations()
      product_2 = product_fixture() |> unload_product_relations()

      assert Products.list_products_by_id([product_1.id, product_2.id]) == [
               product_1,
               product_2
             ]
    end

    test "list_products_by_id/1 returns products only for valid [ids] when a mix
    of valid and invalid ids are passed to the list" do
      product_1 = product_fixture() |> unload_product_relations()
      product_2 = product_fixture() |> unload_product_relations()

      assert Products.list_products_by_id([0, product_1.id, product_2.id]) == [
               product_1,
               product_2
             ]
    end

    test "list_products_by_category_id/1 returns an empty list when category_id
    does not exists" do
      assert Products.list_products_by_category_id(456) == []
    end

    test "list_products_by_category_id/1 returns a list of products matching witch
    category_id" do
      product = product_fixture() |> unload_product_relations()

      assert Products.list_products_by_category_id(product.category_id) == [
               product
             ]
    end

    test "list_products_by_manufacturer_id/1 returns an empty list when
    manufacturer_id does not exists" do
      assert Products.list_products_by_manufacturer_id(456) == []
    end

    test "list_products_by_manufacturer_id/1 returns a list of products matching
    witch manufacturer_id" do
      product = product_fixture() |> unload_product_relations()

      assert Products.list_products_by_manufacturer_id(product.manufacturer_id) ==
               [
                 product
               ]
    end

    test "list_products_by_category_and_manufacturer_id/2 returns all products if
    none of category_id or manufacturer_id are integers" do
      product_1 = product_fixture() |> unload_product_relations()
      product_2 = product_fixture() |> unload_product_relations()

      assert Products.list_products_by_category_and_manufacturer_id("a", "a") ==
               [product_1, product_2]
    end

    test "list_products_by_category_and_manufacturer_id/2 returns an empty list if
    category_id or manufacturer_id are integers but does not exist in the
    database" do
      product = product_fixture()

      assert Products.list_products_by_category_and_manufacturer_id(
               product.category_id,
               456
             ) == []

      assert Products.list_products_by_category_and_manufacturer_id(
               456,
               product.manufacturer_id
             ) == []

      assert Products.list_products_by_category_and_manufacturer_id(456, 456) ==
               []
    end

    test "list_products_by_category_and_manufacturer_id/2 returns product if one
    or both of category_id and manufacturer_id matches products attributes, and
    other inputs are not integers" do
      product = product_fixture() |> unload_product_relations()

      assert Products.list_products_by_category_and_manufacturer_id(
               product.category_id,
               "a"
             ) == [product]

      assert Products.list_products_by_category_and_manufacturer_id(
               "a",
               product.manufacturer_id
             ) == [product]

      assert Products.list_products_by_category_and_manufacturer_id(
               product.category_id,
               product.manufacturer_id
             ) == [product]
    end

    test "get_product!/1 returns the product with given id" do
      product = product_fixture()
      assert Products.get_product!(product.id) == product
    end

    test "create_product/1 with valid data creates a product" do
      _parts = [part_fixture(), part_fixture()]
      # This call is useful until part_fixture() preloads are not removed.
      parts = Products.list_parts()
      part_ids = parts |> Enum.map(fn x -> x.id end)
      valid_attrs = product_valid_attrs() |> Map.put(:part_ids, part_ids)

      assert {:ok, %Product{} = product} = Products.create_product(valid_attrs)

      assert product.parts == parts
      assert product.category_id == valid_attrs.category_id
      assert product.manufacturer_id == valid_attrs.manufacturer_id
      assert product.average_lifetime_m == valid_attrs.average_lifetime_m
      assert product.country_of_origin == valid_attrs.country_of_origin
      assert product.description == valid_attrs.description
      assert product.end_of_production == valid_attrs.end_of_production
      assert product.image == valid_attrs.image
      assert product.name == valid_attrs.name
      assert product.reference == valid_attrs.reference
      assert product.start_of_production == valid_attrs.start_of_production
    end

    test "create_product/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Products.create_product(@invalid_attrs)
    end

    test "update_product/2 with valid data updates the product" do
      product = product_fixture()
      _parts = [part_fixture(), part_fixture()]
      # This call is useful until part_fixture() preloads are not removed.
      parts = Products.list_parts()
      part_ids = parts |> Enum.map(fn x -> x.id end)

      update_attrs = %{
        part_ids: part_ids,
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

      assert product.parts == parts
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

  # TODO: Cancel the part preloads in the fixture and create a helper function
  # in this module to to preloads per tests when necessary.
  # It will allow to remove the parts unloads in create/product test for instance.
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
      _products = [product_fixture(), product_fixture()]
      # This call is useful until product_fixture() preloads are not removed.
      products = Products.list_products()
      product_ids = products |> Enum.map(fn x -> x.id end)
      valid_attrs = part_valid_attrs() |> Map.put(:product_ids, product_ids)

      assert {:ok, %Part{} = part} = Products.create_part(valid_attrs)
      assert part.products == products
      assert part.category_id == valid_attrs.category_id
      assert part.manufacturer_id == valid_attrs.manufacturer_id
      assert part.average_lifetime_m == valid_attrs.average_lifetime_m
      assert part.country_of_origin == valid_attrs.country_of_origin
      assert part.description == valid_attrs.description
      assert part.end_of_production == valid_attrs.end_of_production
      assert part.image == valid_attrs.image
      assert part.main_material == valid_attrs.main_material
      assert part.name == valid_attrs.name
      assert part.reference == valid_attrs.reference
      assert part.start_of_production == valid_attrs.start_of_production
    end

    test "create_part/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Products.create_part(@invalid_attrs)
    end

    test "update_part/2 with valid data updates the part" do
      part = part_fixture()

      _products = [product_fixture(), product_fixture()]
      # This call is useful until product_fixture() preloads are not removed.
      products = Products.list_products()
      product_ids = products |> Enum.map(fn x -> x.id end)

      update_attrs = %{
        product_ids: product_ids,
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

      assert part.products == products
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
