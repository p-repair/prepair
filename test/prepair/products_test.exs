defmodule Prepair.ProductsTest do
  use Prepair.DataCase

  alias Prepair.Products
  alias Prepair.Repo

  import Prepair.NotificationsFixtures
  import Prepair.ProductsFixtures

  @random_uuid_1 Ecto.UUID.generate()
  @random_uuid_2 Ecto.UUID.generate()
  @random_uuid_3 Ecto.UUID.generate()

  describe "manufacturers" do
    alias Prepair.Products.Manufacturer

    @invalid_attrs %{description: nil, image: nil, name: nil}

    test "list_manufacturers/0 returns all manufacturers" do
      manufacturer = manufacturer_fixture()
      assert Products.list_manufacturers() == [manufacturer]
    end

    test "get_manufacturer!/1 returns the manufacturer with given uuid" do
      manufacturer = manufacturer_fixture()
      assert Products.get_manufacturer!(manufacturer.uuid) == manufacturer
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

      assert manufacturer == Products.get_manufacturer!(manufacturer.uuid)
    end

    test "delete_manufacturer/1 deletes the manufacturer" do
      manufacturer = manufacturer_fixture()
      assert {:ok, %Manufacturer{}} = Products.delete_manufacturer(manufacturer)

      assert_raise Ecto.NoResultsError, fn ->
        Products.get_manufacturer!(manufacturer.uuid)
      end
    end

    test "change_manufacturer/1 returns a manufacturer changeset" do
      manufacturer = manufacturer_fixture()
      assert %Ecto.Changeset{} = Products.change_manufacturer(manufacturer)
    end
  end

  describe "categories" do
    alias Prepair.Products.Category

    @invalid_attrs %{
      average_lifetime_m: nil,
      description: nil,
      image: nil,
      name: nil
    }

    test "list_categories/0 returns all categories" do
      category = category_fixture() |> unload_category_relations()
      assert Products.list_categories() == [category]
    end

    test "get_category!/1 returns the category with given uuid" do
      category = category_fixture()
      assert Products.get_category!(category.uuid) == category
    end

    test "create_category/1 with valid data creates a category" do
      notification_templates = create_notification_templates()

      notification_template_uuids =
        create_notification_template_uuids(notification_templates)

      valid_attrs =
        category_valid_attrs()
        |> Map.put(:notification_template_uuids, notification_template_uuids)

      assert {:ok, %Category{} = category} =
               Products.create_category(valid_attrs)

      assert category.notification_templates == notification_templates
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
      notification_templates = create_notification_templates()

      notification_template_uuids =
        create_notification_template_uuids(notification_templates)

      category =
        category_fixture(%{
          notification_template_uuids: notification_template_uuids
        })

      new_notification_templates = create_notification_templates()

      new_notification_template_uuids =
        create_notification_template_uuids(new_notification_templates)

      update_attrs = %{
        notification_template_uuids: new_notification_template_uuids,
        average_lifetime_m: 43,
        description: "some updated description",
        image: "some updated image",
        name: "some updated name"
      }

      assert {:ok, %Category{} = category} =
               Products.update_category(category, update_attrs)

      assert category.notification_templates == new_notification_templates
      assert category.average_lifetime_m == 43
      assert category.description == "some updated description"
      assert category.image == "some updated image"
      assert category.name == "some updated name"
    end

    test "update_category/2 with invalid data returns error changeset" do
      category = category_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Products.update_category(category, @invalid_attrs)

      assert category == Products.get_category!(category.uuid)
    end

    test "delete_category/1 deletes the category" do
      category = category_fixture()
      assert {:ok, %Category{}} = Products.delete_category(category)

      assert_raise Ecto.NoResultsError, fn ->
        Products.get_category!(category.uuid)
      end
    end

    test "change_category/1 returns a category changeset" do
      category = category_fixture()
      assert %Ecto.Changeset{} = Products.change_category(category)
    end
  end

  describe "products" do
    alias Prepair.Products.Product

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

    # Preload fields [:category, :manufacturer, :parts] to be aligned with
    # fuctions tested below, such as get_product!/1 where they are preloaded.
    defp preload_product_relations(product) do
      product
      |> Repo.preload([
        :category,
        :manufacturer,
        :parts,
        :notification_templates
      ])
    end

    test "list_products/1 returns all products when no filters are passed" do
      product = product_fixture()

      assert Products.list_products() == [product]
    end

    test "list_products/1 returns a list of products matching with
    :product_uuids value" do
      product_1 = product_fixture()
      product_2 = product_fixture()

      assert Products.list_products(
               product_uuids: [product_1.uuid, product_2.uuid]
             ) ==
               [
                 product_1,
                 product_2
               ]
    end

    test "list_products/1 returns an empty list when :product_uuids value is a
    list of uuids that does not exists in the database
    exists" do
      assert Products.list_products(
               product_uuids: [@random_uuid_1, @random_uuid_2, @random_uuid_3]
             ) == []
    end

    test "list_products/1 returns a list of products matching with
    :category_uuid value" do
      product = product_fixture()
      _product_2 = product_fixture()

      assert Products.list_products(category_uuid: [product.category_uuid]) == [
               product
             ]
    end

    test "list_products/1 returns an empty list when :category_uuid value is a
    list of uuids that does not exists in the database" do
      assert Products.list_products(category_uuid: [@random_uuid_1]) == []
    end

    test "list_products/1 returns a list of products matching witch
    :manufacturer_uuid value" do
      product = product_fixture()
      _product_2 = product_fixture()

      assert Products.list_products(
               manufacturer_uuid: [product.manufacturer_uuid]
             ) ==
               [
                 product
               ]
    end

    test "list_products/1 returns an empty list when :manufacturer_uuid value is a
    list of uuids that does not exists in the database" do
      assert Products.list_products(manufacturer_uuid: [@random_uuid_1]) == []
    end

    test "list_products/1 returns all products if the value of both :category_uuid
    and :manufacturer_uuid is ['']" do
      product_1 = product_fixture()
      product_2 = product_fixture()

      assert Products.list_products(
               category_uuid: [""],
               manufacturer_uuid: [""]
             ) ==
               [product_1, product_2]
    end

    test "list_products/1 filters can be combined: returns an empty list if
    :category_uuid value is a list of uuids which don’t exist in the database" do
      product = product_fixture()

      assert Products.list_products(
               category_uuid: [@random_uuid_1],
               manufacturer_uuid: [product.manufacturer_uuid]
             ) == []
    end

    test "list_products/1 filters can be combined: returns an empty list if
    :manufacturer_uuid value is a list of uuids which don’t exist in the database" do
      product = product_fixture()

      assert Products.list_products(
               category_uuid: [product.category_uuid],
               manufacturer_uuid: [@random_uuid_1]
             ) == []
    end

    test "list_products/1 filters can be combined: returns an empty list if
    :category_uuid and :manufacturer_uuid values are lists of uuids which don’t
    exist in the database" do
      _product = product_fixture()

      assert Products.list_products(
               category_uuid: [@random_uuid_1],
               manufacturer_uuid: [@random_uuid_2]
             ) ==
               []
    end

    test "list_products/1 returns matching product with :category_uuid value
    when :manufacturer_uuid is set to ['']" do
      category_uuid = category_fixture().uuid
      _product_1 = product_fixture()

      product_2 =
        product_fixture(%{category_uuid: category_uuid})

      assert Products.list_products(
               category_uuid: [category_uuid],
               manufacturer_uuid: [""]
             ) == [product_2]
    end

    test "list_products/1 returns matching product with :manufacturer_uuid value
    when :category_uuid is set to ['']" do
      manufacturer_uuid = manufacturer_fixture().uuid
      _product_1 = product_fixture()

      product_2 =
        product_fixture(%{manufacturer_uuid: manufacturer_uuid})

      assert Products.list_products(
               category_uuid: [""],
               manufacturer_uuid: [manufacturer_uuid]
             ) == [product_2]
    end

    test "list_products/1 filters can be combined: returns matching product with
    :category_uuid and :manufacturer_uuid when both are set" do
      category_uuid = category_fixture().uuid
      manufacturer_uuid = manufacturer_fixture().uuid

      _product_1 =
        product_fixture(%{category_uuid: category_uuid})

      _product_2 =
        product_fixture(%{manufacturer_uuid: manufacturer_uuid})

      product_3 =
        product_fixture(%{
          category_uuid: category_uuid,
          manufacturer_uuid: manufacturer_uuid
        })

      assert Products.list_products(
               category_uuid: [category_uuid],
               manufacturer_uuid: [manufacturer_uuid]
             ) == [product_3]
    end

    test "list_products/1 raises when applying as a filter an atom which does
    not exist in product schema fields" do
      assert_raise Ecto.QueryError, fn ->
        Products.list_products(random_filter: [0])
      end
    end

    test "list_products_by_uuid/1 returns an empty list when none of [uuids] exist" do
      assert Products.list_products_by_uuid([
               @random_uuid_1,
               @random_uuid_2,
               @random_uuid_3
             ]) == []
    end

    test "list_products_by_uuid/1 returns a list of products matching witch [uuids]" do
      product_1 = product_fixture()
      product_2 = product_fixture()

      assert Products.list_products_by_uuid([product_1.uuid, product_2.uuid]) ==
               [
                 product_1,
                 product_2
               ]
    end

    test "list_products_by_uuid/1 returns products only for valid [uuids] when a mix
    of valid and invalid uuids are passed to the list" do
      product_1 = product_fixture()
      product_2 = product_fixture()

      assert Products.list_products_by_uuid([product_1.uuid, product_2.uuid]) ==
               [
                 product_1,
                 product_2
               ]
    end

    test "get_product!/1 returns the product with given uuid" do
      product = product_fixture() |> preload_product_relations()
      assert Products.get_product!(product.uuid) == product
    end

    test "create_product/1 with valid data creates a product" do
      parts = create_parts()
      part_uuids = create_part_uuids(parts)
      notification_templates = create_notification_templates()

      notification_template_uuids =
        create_notification_template_uuids(notification_templates)

      valid_attrs =
        product_valid_attrs()
        |> Map.put(:part_uuids, part_uuids)
        |> Map.put(:notification_template_uuids, notification_template_uuids)

      assert {:ok, %Product{} = product} = Products.create_product(valid_attrs)

      assert product.notification_templates == notification_templates
      assert product.parts == parts
      assert product.category_uuid == valid_attrs.category_uuid
      assert product.manufacturer_uuid == valid_attrs.manufacturer_uuid
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
      parts = create_parts()
      part_uuids = create_part_uuids(parts)
      notification_templates = create_notification_templates()

      notification_template_uuids =
        create_notification_template_uuids(notification_templates)

      product =
        product_fixture(%{
          notification_template_uuids: notification_template_uuids,
          part_uuids: part_uuids
        })
        |> preload_product_relations()

      new_parts = create_parts()
      new_part_uuids = create_part_uuids(new_parts)
      new_notification_templates = create_notification_templates()

      new_notification_template_uuids =
        create_notification_template_uuids(new_notification_templates)

      update_attrs = %{
        notification_template_uuids: new_notification_template_uuids,
        part_uuids: new_part_uuids,
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

      assert product.notification_templates == new_notification_templates
      assert product.parts == new_parts
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
      product = product_fixture() |> preload_product_relations()

      assert {:error, %Ecto.Changeset{}} =
               Products.update_product(product, @invalid_attrs)

      assert product == Products.get_product!(product.uuid)
    end

    test "delete_product/1 deletes the product" do
      product = product_fixture()
      assert {:ok, %Product{}} = Products.delete_product(product)

      assert_raise Ecto.NoResultsError, fn ->
        Products.get_product!(product.uuid)
      end
    end

    test "change_product/1 returns a product changeset" do
      product = product_fixture() |> preload_product_relations()
      assert %Ecto.Changeset{} = Products.change_product(product)
    end
  end

  describe "parts" do
    alias Prepair.Products.Part

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
      part = part_fixture() |> unload_part_relations()
      assert Products.list_parts() == [part]
    end

    test "get_part!/1 returns the part with given uuid" do
      part = part_fixture()
      assert Products.get_part!(part.uuid) == part
    end

    test "create_part/1 with valid data creates a part" do
      products = create_products()
      product_uuids = create_product_uuids(products)
      notification_templates = create_notification_templates()

      notification_template_uuids =
        create_notification_template_uuids(notification_templates)

      valid_attrs =
        part_valid_attrs()
        |> Map.put(:product_uuids, product_uuids)
        |> Map.put(:notification_template_uuids, notification_template_uuids)

      assert {:ok, %Part{} = part} = Products.create_part(valid_attrs)
      assert part.notification_templates == notification_templates
      assert part.products == products
      assert part.category_uuid == valid_attrs.category_uuid
      assert part.manufacturer_uuid == valid_attrs.manufacturer_uuid
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
      products = create_products()
      product_uuids = create_product_uuids(products)
      notification_templates = create_notification_templates()

      notification_template_uuids =
        create_notification_template_uuids(notification_templates)

      part =
        part_fixture(%{
          notification_template_uuids: notification_template_uuids,
          product_uuids: product_uuids
        })

      new_products = create_products()
      new_product_uuids = create_product_uuids(new_products)
      new_notification_templates = create_notification_templates()

      new_notification_template_uuids =
        create_notification_template_uuids(new_notification_templates)

      update_attrs = %{
        notification_template_uuids: new_notification_template_uuids,
        product_uuids: new_product_uuids,
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

      assert part.notification_templates == new_notification_templates
      assert part.products == new_products
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

      assert part == Products.get_part!(part.uuid)
    end

    test "delete_part/1 deletes the part" do
      part = part_fixture()
      assert {:ok, %Part{}} = Products.delete_part(part)
      assert_raise Ecto.NoResultsError, fn -> Products.get_part!(part.uuid) end
    end

    test "change_part/1 returns a part changeset" do
      part = part_fixture()
      assert %Ecto.Changeset{} = Products.change_part(part)
    end
  end
end
