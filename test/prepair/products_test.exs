defmodule Prepair.LegacyContexts.ProductsTest do
  use Prepair.DataCase

  alias Prepair.LegacyContexts.Products
  alias Prepair.Repo

  import Prepair.LegacyContexts.NotificationsFixtures
  import Prepair.LegacyContexts.ProductsFixtures

  @random_id_1 Ecto.UUID.generate()
  @random_id_2 Ecto.UUID.generate()
  @random_id_3 Ecto.UUID.generate()

  describe "manufacturers" do
    alias Prepair.LegacyContexts.Products.Manufacturer

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
    alias Prepair.LegacyContexts.Products.Category

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

    test "get_category!/1 returns the category with given id" do
      category = category_fixture()
      assert Products.get_category!(category.id) == category
    end

    test "create_category/1 with valid data creates a category" do
      notification_templates = create_notification_templates()

      notification_template_ids =
        create_notification_template_ids(notification_templates)

      valid_attrs =
        category_valid_attrs()
        |> Map.put(:notification_template_ids, notification_template_ids)

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

      notification_template_ids =
        create_notification_template_ids(notification_templates)

      category =
        category_fixture(%{
          notification_template_ids: notification_template_ids
        })

      new_notification_templates = create_notification_templates()

      new_notification_template_ids =
        create_notification_template_ids(new_notification_templates)

      update_attrs = %{
        notification_template_ids: new_notification_template_ids,
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
    alias Prepair.LegacyContexts.Products.Product

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
    :product_ids value" do
      product_1 = product_fixture()
      product_2 = product_fixture()

      assert Products.list_products(product_ids: [product_1.id, product_2.id]) ==
               [
                 product_1,
                 product_2
               ]
    end

    test "list_products/1 returns an empty list when :product_ids value is a
    list of ids that does not exists in the database
    exists" do
      assert Products.list_products(
               product_ids: [@random_id_1, @random_id_2, @random_id_3]
             ) == []
    end

    test "list_products/1 returns a list of products matching with
    :category_id value" do
      product = product_fixture()
      _product_2 = product_fixture()

      assert Products.list_products(category_id: [product.category_id]) == [
               product
             ]
    end

    test "list_products/1 returns an empty list when :category_id value is a
    list of ids that does not exists in the database" do
      assert Products.list_products(category_id: [@random_id_1]) == []
    end

    test "list_products/1 returns a list of products matching witch
    :manufacturer_id value" do
      product = product_fixture()
      _product_2 = product_fixture()

      assert Products.list_products(manufacturer_id: [product.manufacturer_id]) ==
               [
                 product
               ]
    end

    test "list_products/1 returns an empty list when :manufacturer_id value is a
    list of ids that does not exists in the database" do
      assert Products.list_products(manufacturer_id: [@random_id_1]) == []
    end

    test "list_products/1 returns all products if the value of both :category_id
    and :manufacturer_id is ['']" do
      product_1 = product_fixture()
      product_2 = product_fixture()

      assert Products.list_products(
               category_id: [""],
               manufacturer_id: [""]
             ) ==
               [product_1, product_2]
    end

    test "list_products/1 filters can be combined: returns an empty list if
    :category_id value is a list of ids which don’t exist in the database" do
      product = product_fixture()

      assert Products.list_products(
               category_id: [@random_id_1],
               manufacturer_id: [product.manufacturer_id]
             ) == []
    end

    test "list_products/1 filters can be combined: returns an empty list if
    :manufacturer_id value is a list of ids which don’t exist in the database" do
      product = product_fixture()

      assert Products.list_products(
               category_id: [product.category_id],
               manufacturer_id: [@random_id_1]
             ) == []
    end

    test "list_products/1 filters can be combined: returns an empty list if
    :category_id and :manufacturer_id values are lists of ids which don’t
    exist in the database" do
      _product = product_fixture()

      assert Products.list_products(
               category_id: [@random_id_1],
               manufacturer_id: [@random_id_2]
             ) ==
               []
    end

    test "list_products/1 returns matching product with :category_id value
    when :manufacturer_id is set to ['']" do
      category_id = category_fixture().id
      _product_1 = product_fixture()

      product_2 =
        product_fixture(%{category_id: category_id})

      assert Products.list_products(
               category_id: [category_id],
               manufacturer_id: [""]
             ) == [product_2]
    end

    test "list_products/1 returns matching product with :manufacturer_id value
    when :category_id is set to ['']" do
      manufacturer_id = manufacturer_fixture().id
      _product_1 = product_fixture()

      product_2 =
        product_fixture(%{manufacturer_id: manufacturer_id})

      assert Products.list_products(
               category_id: [""],
               manufacturer_id: [manufacturer_id]
             ) == [product_2]
    end

    test "list_products/1 filters can be combined: returns matching product with
    :category_id and :manufacturer_id when both are set" do
      category_id = category_fixture().id
      manufacturer_id = manufacturer_fixture().id

      _product_1 =
        product_fixture(%{category_id: category_id})

      _product_2 =
        product_fixture(%{manufacturer_id: manufacturer_id})

      product_3 =
        product_fixture(%{
          category_id: category_id,
          manufacturer_id: manufacturer_id
        })

      assert Products.list_products(
               category_id: [category_id],
               manufacturer_id: [manufacturer_id]
             ) == [product_3]
    end

    test "list_products/1 raises when applying as a filter an atom which does
    not exist in product schema fields" do
      assert_raise Ecto.QueryError, fn ->
        Products.list_products(random_filter: [0])
      end
    end

    test "list_products_by_id/1 returns an empty list when none of [ids] exist" do
      assert Products.list_products_by_id([
               @random_id_1,
               @random_id_2,
               @random_id_3
             ]) == []
    end

    test "list_products_by_id/1 returns a list of products matching witch [ids]" do
      product_1 = product_fixture()
      product_2 = product_fixture()

      assert Products.list_products_by_id([product_1.id, product_2.id]) ==
               [
                 product_1,
                 product_2
               ]
    end

    test "list_products_by_id/1 returns products only for valid [ids] when a mix
    of valid and invalid ids are passed to the list" do
      product_1 = product_fixture()
      product_2 = product_fixture()

      assert Products.list_products_by_id([product_1.id, product_2.id]) ==
               [
                 product_1,
                 product_2
               ]
    end

    test "get_product!/1 returns the product with given id" do
      product = product_fixture() |> preload_product_relations()
      assert Products.get_product!(product.id) == product
    end

    test "create_product/1 with valid data creates a product" do
      parts = create_parts()
      part_ids = create_part_ids(parts)
      notification_templates = create_notification_templates()

      notification_template_ids =
        create_notification_template_ids(notification_templates)

      valid_attrs =
        product_valid_attrs()
        |> Map.put(:part_ids, part_ids)
        |> Map.put(:notification_template_ids, notification_template_ids)

      assert {:ok, %Product{} = product} = Products.create_product(valid_attrs)

      assert product.notification_templates == notification_templates
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
      parts = create_parts()
      part_ids = create_part_ids(parts)
      notification_templates = create_notification_templates()

      notification_template_ids =
        create_notification_template_ids(notification_templates)

      product =
        product_fixture(%{
          notification_template_ids: notification_template_ids,
          part_ids: part_ids
        })
        |> preload_product_relations()

      new_parts = create_parts()
      new_part_ids = create_part_ids(new_parts)
      new_notification_templates = create_notification_templates()

      new_notification_template_ids =
        create_notification_template_ids(new_notification_templates)

      update_attrs = %{
        notification_template_ids: new_notification_template_ids,
        part_ids: new_part_ids,
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
      product = product_fixture() |> preload_product_relations()
      assert %Ecto.Changeset{} = Products.change_product(product)
    end
  end

  describe "parts" do
    alias Prepair.LegacyContexts.Products.Part

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

    test "get_part!/1 returns the part with given id" do
      part = part_fixture()
      assert Products.get_part!(part.id) == part
    end

    test "create_part/1 with valid data creates a part" do
      products = create_products()
      product_ids = create_product_ids(products)
      notification_templates = create_notification_templates()

      notification_template_ids =
        create_notification_template_ids(notification_templates)

      valid_attrs =
        part_valid_attrs()
        |> Map.put(:product_ids, product_ids)
        |> Map.put(:notification_template_ids, notification_template_ids)

      assert {:ok, %Part{} = part} = Products.create_part(valid_attrs)
      assert part.notification_templates == notification_templates
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
      products = create_products()
      product_ids = create_product_ids(products)
      notification_templates = create_notification_templates()

      notification_template_ids =
        create_notification_template_ids(notification_templates)

      part =
        part_fixture(%{
          notification_template_ids: notification_template_ids,
          product_ids: product_ids
        })

      new_products = create_products()
      new_product_ids = create_product_ids(new_products)
      new_notification_templates = create_notification_templates()

      new_notification_template_ids =
        create_notification_template_ids(new_notification_templates)

      update_attrs = %{
        notification_template_ids: new_notification_template_ids,
        product_ids: new_product_ids,
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
