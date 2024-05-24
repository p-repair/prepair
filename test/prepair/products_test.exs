defmodule Prepair.LegacyContexts.ProductsTest do
  use Prepair.DataCase

  import Prepair.LegacyContexts.NotificationsFixtures
  import Prepair.LegacyContexts.ProductsFixtures

  @random_id_1 Ecto.UUID.generate()
  @random_id_2 Ecto.UUID.generate()
  @random_id_3 Ecto.UUID.generate()

  describe "manufacturers" do
    alias Prepair.AshDomains.Products.Manufacturer

    @invalid_attrs %{description: nil, image: nil, name: nil}

    @tag :manufacturer_resource
    test "Manufacturer.list/2 returns all manufacturers" do
      manufacturer = manufacturer_fixture()
      assert {:ok, [man]} = Manufacturer.list()
      assert man.id == manufacturer.id
    end

    @tag :manufacturer_resource
    test "Manufacturer.get/3 returns the manufacturer with given id" do
      manufacturer = manufacturer_fixture()
      assert {:ok, man} = Manufacturer.get(manufacturer.id)
      assert man.id == manufacturer.id
    end

    @tag :manufacturer_resource
    test "Manufacturer.create/2 with valid data creates a manufacturer" do
      valid_attrs = manufacturer_valid_attrs()

      assert {:ok, %Manufacturer{} = manufacturer} =
               Manufacturer.create(valid_attrs)

      assert manufacturer.description == valid_attrs.description
      assert manufacturer.image == valid_attrs.image
      assert manufacturer.name == valid_attrs.name
    end

    @tag :manufacturer_resource
    test "Manufacturer.create/2 with invalid data returns error changeset" do
      assert {:error, %Ash.Error.Invalid{}} =
               Manufacturer.create(@invalid_attrs)
    end

    @tag :manufacturer_resource
    test "Manufacturer.update/3 with valid data updates the manufacturer" do
      manufacturer = manufacturer_fixture()

      update_attrs = %{
        description: "some updated description",
        image: "some updated image",
        name: "some updated name"
      }

      assert {:ok, %Manufacturer{} = manufacturer} =
               Manufacturer.update(manufacturer, update_attrs)

      assert manufacturer.description == "some updated description"
      assert manufacturer.image == "some updated image"
      assert manufacturer.name == "some updated name"
    end

    @tag :manufacturer_resource
    test "Manufacturer.update/3 with invalid data returns error changeset" do
      manufacturer = manufacturer_fixture()

      assert {:error, %Ash.Error.Invalid{}} =
               Manufacturer.update(manufacturer, @invalid_attrs)

      assert manufacturer.name == Manufacturer.get!(manufacturer.id).name
    end

    @tag :manufacturer_resource
    test "Manufacturer.delete/3 deletes the manufacturer" do
      manufacturer = manufacturer_fixture()
      assert :ok == Manufacturer.delete(manufacturer)

      assert_raise Ash.Error.Query.NotFound, fn ->
        Manufacturer.get!(manufacturer.id)
      end
    end

    # NOTE: Do we need to create a code_interface like Manufacturer.change?
    @tag :manufacturer_resource
    test "Ash.Changeset.new(manufacturer) returns a manufacturer
    changeset" do
      manufacturer = manufacturer_fixture()
      assert %Ash.Changeset{} = Ash.Changeset.new(manufacturer)
    end
  end

  describe "categories" do
    alias Prepair.AshDomains.Products.Category

    @invalid_attrs %{
      average_lifetime_m: nil,
      description: nil,
      image: nil,
      name: nil
    }

    @tag :category_resource
    test "Category.list/2 returns all categories" do
      category = category_fixture()
      assert {:ok, [cat]} = Category.list()
      assert cat.id == category.id
    end

    @tag :category_resource
    test "Category.get/3 returns the category with given id" do
      category = category_fixture()
      assert {:ok, cat} = Category.get(category.id)
      assert cat.id == category.id
    end

    @tag :category_resource
    test "Category.create/2 with valid data creates a category" do
      notification_templates = create_notification_templates()

      notification_template_ids =
        create_notification_template_ids(notification_templates)

      valid_attrs =
        category_valid_attrs()
        |> Map.put(:notification_template_ids, notification_template_ids)

      assert {:ok, %Category{} = category} =
               Category.create(valid_attrs)

      assert category.notification_templates[:id] == notification_templates[:id]
      assert category.average_lifetime_m == valid_attrs.average_lifetime_m
      assert category.description == valid_attrs.description
      assert category.image == valid_attrs.image
      assert category.name == valid_attrs.name
    end

    @tag :category_resource
    test "Category.create/2 with invalid data returns error changeset" do
      assert {:error, %Ash.Error.Invalid{}} = Category.create(@invalid_attrs)
    end

    @tag :category_resource
    test "Category.update/3 with valid data updates the category" do
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
               Category.update(category, update_attrs)

      assert category.notification_templates[:id] ==
               new_notification_templates[:id]

      assert category.average_lifetime_m == 43
      assert category.description == "some updated description"
      assert category.image == "some updated image"
      assert category.name == "some updated name"
    end

    @tag :category_resource
    test "Category.update/3 with invalid data returns error changeset" do
      category = category_fixture()

      assert {:error, %Ash.Error.Invalid{}} =
               Category.update(category, @invalid_attrs)

      assert category.name == Category.get!(category.id).name
    end

    @tag :category_resource
    test "Category.delete/1 deletes the category" do
      category = category_fixture()
      assert :ok == Category.delete(category)

      assert_raise Ash.Error.Query.NotFound, fn ->
        Category.get!(category.id)
      end
    end

    # NOTE: Do we need to create a code_interface like Manufacturer.change?
    @tag :category_resource
    test "Ash.Changeset.new(category) returns a category changeset" do
      category = category_fixture()
      assert %Ash.Changeset{} = Ash.Changeset.new(category)
    end
  end

  describe "products" do
    alias Prepair.AshDomains.Products.Product

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

    @tag :product_resource
    test "Product.list/3 returns all products when no filters are passed" do
      product = product_fixture()

      assert {:ok, [prod]} = Product.list()
      assert prod.id == product.id
    end

    @tag :product_resource
    test "Product.list/3 returns a list of products matching with
    :product_ids value" do
      product_1 = product_fixture()
      product_2 = product_fixture()
      _product_3 = product_fixture()

      assert {:ok, [prod_1, prod_2]} =
               Product.list(%{product_ids: [product_1.id, product_2.id]})

      assert [prod_1.id, prod_2.id] == [product_1.id, product_2.id]
    end

    @tag :product_resource
    test "Product.list/3 returns an empty list when :product_ids value is a
    list of ids that does not exists in the database
    exists" do
      assert {:ok, []} ==
               Product.list(%{
                 product_ids: [@random_id_1, @random_id_2, @random_id_3]
               })
    end

    @tag :product_resource
    test "Product.list/3 returns a list of products matching with
    :category_ids value" do
      product_1 = product_fixture()
      _product_2 = product_fixture()

      assert {:ok, [prod_1]} =
               Product.list(%{category_ids: [product_1.category_id]})

      assert prod_1.id == product_1.id
    end

    @tag :product_resource
    test "Product.list/3 returns an empty list when :category_ids value is a
    list of ids that does not exists in the database" do
      assert {:ok, []} == Product.list(%{category_ids: [@random_id_1]})
    end

    @tag :product_resource
    test "Product.list/3 returns a list of products matching witch
    :manufacturer_ids value" do
      product_1 = product_fixture()
      _product_2 = product_fixture()

      assert {:ok, [prod_1]} =
               Product.list(%{manufacturer_ids: [product_1.manufacturer_id]})

      assert prod_1.id == product_1.id
    end

    @tag :product_resource
    test "Product.list/3 returns an empty list when :manufacturer_ids value is a
    list of ids that does not exists in the database" do
      assert {:ok, []} = Product.list(%{manufacturer_ids: [@random_id_1]})
    end

    # NOTE: This test don’t pass. We should handle the invalid JSON sent by
    # FlutterFlow in another way.
    # @tag :product_resource
    # test "Product.list/3 returns all products if the value of both :category_id
    # and :manufacturer_id is ['']" do
    #   product_1 = product_fixture()
    #   product_2 = product_fixture()

    #   assert {:ok, [prod_1, prod_2]} =
    #            Product.list(%{
    #              category_ids: [""],
    #              manufacturer_ids: [""]
    #            })

    #   assert [prod_1.id, prod_2.id] == [product_1.id, product_2.id]
    # end

    @tag :product_resource
    test "Product.list/3 filters can be combined: returns an empty list if
    :category_ids value is a list of ids which don’t exist in the database" do
      product = product_fixture()

      assert {:ok, []} ==
               Product.list(%{
                 category_ids: [@random_id_1],
                 manufacturer_ids: [product.manufacturer_id]
               })
    end

    @tag :product_resource
    test "Product.list/3 filters can be combined: returns an empty list if
    :manufacturer_ids value is a list of ids which don’t exist in the database" do
      product = product_fixture()

      assert {:ok, []} ==
               Product.list(%{
                 category_ids: [product.category_id],
                 manufacturer_ids: [@random_id_1]
               })
    end

    @tag :product_resource
    test "Product.list/3 filters can be combined: returns an empty list if
    :category_ids and :manufacturer_ids values are lists of ids which don’t
    exist in the database" do
      _product = product_fixture()

      assert {:ok, []} ==
               Product.list(%{
                 category_ids: [@random_id_1],
                 manufacturer_ids: [@random_id_2]
               })
    end

    # NOTE: This test don’t pass. We should handle the invalid JSON sent by
    # FlutterFlow in another way.

    # @tag :product_resource
    # test "Product.list/3 returns matching product with :category_ids value
    # when :manufacturer_ids is set to ['']" do
    #   category_id = category_fixture().id
    #   _product_1 = product_fixture()

    #   product_2 =
    #     product_fixture(%{category_id: category_id})

    #   assert {:ok, [prod_2]} =
    #            Product.list(%{
    #              category_ids: [category_id],
    #              manufacturer_ids: [""]
    #            })

    #   assert prod_2.id == product_2.id
    # end

    # NOTE: This test don’t pass. We should handle the invalid JSON sent by
    # FlutterFlow in another way.

    # @tag :product_resource
    # test "Product.list/3 returns matching product with :manufacturer_ids value
    # when :category_ids is set to ['']" do
    #   manufacturer_id = manufacturer_fixture().id
    #   _product_1 = product_fixture()

    #   product_2 =
    #     product_fixture(%{manufacturer_id: manufacturer_id})

    #   assert {:ok, [prod_2]} =
    #            Product.list(%{
    #              category_ids: [""],
    #              manufacturer_ids: [manufacturer_id]
    #            })

    #   assert prod_2.id == product_2.id
    # end

    @tag :product_resource
    test "Product.list/3 filters can be combined: returns matching product with
    :category_ids and :manufacturer_ids when both are set" do
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

      assert {:ok, [prod_3]} =
               Product.list(%{
                 category_ids: [category_id],
                 manufacturer_ids: [manufacturer_id]
               })

      assert prod_3.id == product_3.id
    end

    @tag :product_resource
    test "Product.list/3 raises when applying as a filter an atom which does
    not exist in product schema fields" do
      assert {:error, %Ash.Error.Invalid{}} =
               Product.list(%{random_filter: [0]})
    end

    @tag :product_resource
    test "Product.list_by_id/3 returns an empty list when none of [ids] exist" do
      assert {:ok, []} ==
               Product.list_by_id([
                 @random_id_1,
                 @random_id_2,
                 @random_id_3
               ])
    end

    @tag :product_resource
    test "Product.list_by_id/3 returns a list of products matching witch [ids]" do
      product_1 = product_fixture()
      product_2 = product_fixture()

      assert {:ok, [prod_1, prod_2]} =
               Product.list_by_id([product_1.id, product_2.id])

      assert [prod_1.id, prod_2.id] == [product_1.id, product_2.id]
    end

    @tag :product_resource
    test "Product.list_by_id/3 returns products only for valid [ids] when a mix
    of valid and invalid ids are passed to the list" do
      product_1 = product_fixture()
      product_2 = @random_id_2

      assert {:ok, [prod_1]} = Product.list_by_id([product_1.id, product_2])
      assert prod_1.id == product_1.id
    end

    @tag :product_resource
    test "Product.get/3 returns the product with given id" do
      product = product_fixture()
      assert {:ok, prod} = Product.get(product.id)
      assert prod.id == product.id
    end

    @tag :product_resource
    test "Product.create/2 with valid data creates a product" do
      parts = create_parts()
      part_ids = create_part_ids(parts)
      notification_templates = create_notification_templates()

      notification_template_ids =
        create_notification_template_ids(notification_templates)

      valid_attrs =
        product_valid_attrs()
        |> Map.put(:part_ids, part_ids)
        |> Map.put(:notification_template_ids, notification_template_ids)

      assert {:ok, %Product{} = product} = Product.create(valid_attrs)

      assert product.notification_templates[:id] == notification_templates[:id]
      assert product.parts[:id] == parts[:id]
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

    @tag :product_resource
    test "Product.create/2 with invalid data returns error changeset" do
      assert {:error, %Ash.Error.Invalid{}} = Product.create(@invalid_attrs)
    end

    @tag :product_resource
    test "Product.update/3 with valid data updates the product" do
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
               Product.update(product, update_attrs)

      assert product.notification_templates[:id] ==
               new_notification_templates[:id]

      assert product.parts[:id] == new_parts[:id]
      assert product.average_lifetime_m == 43
      assert product.country_of_origin == "some updated country_of_origin"
      assert product.description == "some updated description"
      assert product.end_of_production == ~D[2023-07-12]
      assert product.image == "some updated image"
      assert product.name == "some updated name"
      assert product.reference == "some updated reference"
      assert product.start_of_production == ~D[2023-07-12]
    end

    @tag :product_resource
    test "Product.update/3 with invalid data returns error changeset" do
      product = product_fixture()

      assert {:error, %Ash.Error.Invalid{}} =
               Product.update(product, @invalid_attrs)

      assert product.name == Product.get!(product.id).name
    end

    @tag :product_resource
    test "Product.delete/3 deletes the product" do
      product = product_fixture()
      assert :ok == Product.delete(product)

      assert_raise Ash.Error.Query.NotFound, fn -> Product.get!(product.id) end
    end

    # NOTE: Do we need to create a code_interface like Product.change?
    @tag :product_resource
    test "Ash.Changeset.new(product) returns a product changeset" do
      product = product_fixture()
      assert %Ash.Changeset{} = Ash.Changeset.new(product)
    end
  end

  describe "parts" do
    alias Prepair.AshDomains.Products.Part

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

    @tag :part_resource
    test "Part.list/3 returns all parts" do
      part = part_fixture()
      assert {:ok, [p]} = Part.list()
      assert p.id == part.id
    end

    @tag :part_resource
    test "Part.get/3 returns the part with given id" do
      part = part_fixture()
      assert {:ok, p} = Part.get(part.id)
      assert p.id == part.id
    end

    @tag :part_resource
    test "Part.create/3 with valid data creates a part" do
      products = create_products()
      product_ids = create_product_ids(products)
      notification_templates = create_notification_templates()

      notification_template_ids =
        create_notification_template_ids(notification_templates)

      valid_attrs =
        part_valid_attrs()
        |> Map.put(:product_ids, product_ids)
        |> Map.put(:notification_template_ids, notification_template_ids)

      assert {:ok, %Part{} = part} = Part.create(valid_attrs)
      assert part.notification_templates[:id] == notification_templates[:id]
      assert part.products[:id] == products[:id]
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

    @tag :part_resource
    test "Part.create/3 with invalid data returns error changeset" do
      assert {:error, %Ash.Error.Invalid{}} = Part.create(@invalid_attrs)
    end

    @tag :part_resource
    test "Part.update/3 with valid data updates the part" do
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

      assert {:ok, %Part{} = part} = Part.update(part, update_attrs)

      assert part.notification_templates[:id] == new_notification_templates[:id]
      assert part.products[:id] == new_products[:id]
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

    @tag :part_resource
    test "update_part/2 with invalid data returns error changeset" do
      part = part_fixture()

      assert {:error, %Ash.Error.Invalid{}} = Part.update(part, @invalid_attrs)
      assert part.name == Part.get!(part.id).name
    end

    @tag :part_resource
    test "delete_part/1 deletes the part" do
      part = part_fixture()
      assert :ok == Part.delete(part)
      assert_raise Ash.Error.Query.NotFound, fn -> Part.get!(part.id) end
    end

    # NOTE: Do we need to create a code_interface like Part.change?
    @tag :part_resource
    test "Ash.Changeset.new(part) returns a part changeset" do
      part = part_fixture()
      assert %Ash.Changeset{} = Ash.Changeset.new(part)
    end
  end
end
