defmodule Prepair.LegacyContexts.NotificationsTest do
  use Prepair.DataCase

  describe "notification_templates" do
    alias Prepair.AshDomains.Notifications.NotificationTemplate

    import Prepair.LegacyContexts.NotificationsFixtures
    import Prepair.LegacyContexts.ProductsFixtures

    @invalid_attrs %{
      name: nil,
      description: nil,
      title: nil,
      content: nil,
      condition: nil,
      need_action: nil,
      draft: nil
    }

    @random_id_1 Ecto.UUID.generate()
    @random_id_2 Ecto.UUID.generate()
    @random_id_3 Ecto.UUID.generate()

    @tag :notification_template_resource
    test "NotificationTemplate.list/3 returns all notification_templates when
    no filters are passed" do
      notification_template = notification_template_fixture()

      assert {:ok, [n]} = NotificationTemplate.list()
      assert n.id == notification_template.id
    end

    @tag :notification_template_resource
    test "NotificationTemplate.list/3 returns a list of notification_templates
     matching with :category_ids value" do
      category_1_id = category_fixture().id
      category_2_id = category_fixture().id

      notification_template_1 =
        notification_template_fixture(%{
          category_ids: [category_1_id, category_2_id]
        })

      notification_template_2 =
        notification_template_fixture(%{category_ids: [category_1_id]})

      _notification_template_3 =
        notification_template_fixture(%{category_ids: [category_2_id]})

      assert {:ok, [n1, n2]} =
               NotificationTemplate.list(%{category_ids: [category_1_id]})

      assert [n1.id, n2.id] ==
               [notification_template_1.id, notification_template_2.id]
    end

    @tag :notification_template_resource
    test "NotificationTemplate.list/3 returns an empty list when
    :category_ids value is a list of ids that does not exists in the database" do
      assert {:ok, []} ==
               NotificationTemplate.list(%{
                 category_ids: [@random_id_1, @random_id_2, @random_id_3]
               })
    end

    @tag :notification_template_resource
    test "NotificationTemplate.list/3 returns a list of notification_templates
    matching with :product_ids value" do
      product_1_id = product_fixture().id
      product_2_id = product_fixture().id

      notification_template_1 =
        notification_template_fixture(%{
          product_ids: [product_1_id, product_2_id]
        })

      notification_template_2 =
        notification_template_fixture(%{product_ids: [product_1_id]})

      _notification_template_3 =
        notification_template_fixture(%{product_ids: [product_2_id]})

      assert {:ok, [n1, n2]} =
               NotificationTemplate.list(%{product_ids: [product_1_id]})

      assert [n1.id, n2.id] == [
               notification_template_1.id,
               notification_template_2.id
             ]
    end

    @tag :notification_template_resource
    test "NotificationTemplate.list/3 returns an empty list when :product_ids
    value is a list of ids that does not exists in the database" do
      assert {:ok, []} ==
               NotificationTemplate.list(%{product_ids: [@random_id_1]})
    end

    @tag :notification_template_resource
    test "NotificationTemplate.list/3 returns a list of notification_templates
     matching witch :part_ids value" do
      part_1_id = part_fixture().id
      part_2_id = part_fixture().id

      notification_template_1 =
        notification_template_fixture(%{
          part_ids: [part_1_id, part_2_id]
        })

      notification_template_2 =
        notification_template_fixture(%{part_ids: [part_1_id]})

      _notification_template_3 =
        notification_template_fixture(%{part_ids: [part_2_id]})

      assert {:ok, [n1, n2]} =
               NotificationTemplate.list(%{part_ids: [part_1_id]})

      assert [n1.id, n2.id] == [
               notification_template_1.id,
               notification_template_2.id
             ]
    end

    @tag :notification_template_resource
    test "NotificationTemplate.list/3 returns an empty list when :part_ids
    value is a list of ids that does not exists in the database" do
      assert {:ok, []} == NotificationTemplate.list(%{part_ids: [@random_id_1]})
    end

    @tag :notification_template_resource
    test "NotificationTemplate.list/3 filters can be combined: returns an
    empty list if :category_ids value is a list of ids which don’t exist in the
    database" do
      product_1_id = product_fixture().id

      _notification_template_1 =
        notification_template_fixture(%{product_ids: [product_1_id]})

      assert {:ok, []} ==
               NotificationTemplate.list(%{
                 category_ids: [@random_id_1],
                 product_ids: [product_1_id]
               })
    end

    @tag :notification_template_resource
    test "NotificationTemplate.list/3 filters can be combined: returns an
    empty list if :product_ids value is a list of ids which don’t exist in the
    database" do
      category_id_1 = category_fixture().id

      _notification_template_1 =
        notification_template_fixture(%{category_ids: [category_id_1]})

      assert {:ok, []} ==
               NotificationTemplate.list(%{
                 category_ids: [category_id_1],
                 product_ids: [@random_id_1]
               })
    end

    @tag :notification_template_resource
    test "NotificationTemplate.list/3 filters can be combined: returns an
    empty list if :part_ids value is a list of ids which don’t exist in the
    database" do
      category_id_1 = category_fixture().id

      _notification_template_1 =
        notification_template_fixture(%{category_ids: [category_id_1]})

      assert {:ok, []} ==
               NotificationTemplate.list(%{
                 category_ids: [category_id_1],
                 part_ids: [@random_id_1]
               })
    end

    @tag :notification_template_resource
    test "NotificationTemplate.list/3 filters can be combined: returns an
    empty list if :category_ids, :product_ids and :part_ids values are lists of
    ids which don’t match on the same notification_templates" do
      category_id_1 = category_fixture().id
      product_id_1 = product_fixture().id
      part_id_1 = part_fixture().id

      _notification_template_1 =
        notification_template_fixture(%{category_ids: [category_id_1]})

      _notification_template_2 =
        notification_template_fixture(%{product_ids: [product_id_1]})

      _notification_template_3 =
        notification_template_fixture(%{part_ids: [part_id_1]})

      assert {:ok, []} ==
               NotificationTemplate.list(%{
                 category_ids: [category_id_1],
                 product_ids: [product_id_1],
                 part_ids: [part_id_1]
               })
    end

    @tag :notification_template_resource
    test "NotificationTemplate.list/3 filters can be combined: returns
    matching notification_templates with :category_ids, :product_ids and
    :part_ids when all are set" do
      category_id_1 = category_fixture().id
      product_id_1 = product_fixture().id
      part_id_1 = part_fixture().id

      _notification_template_1 =
        notification_template_fixture(%{category_ids: [category_id_1]})

      _notification_template_2 =
        notification_template_fixture(%{
          category_ids: [category_id_1],
          product_ids: [product_id_1]
        })

      notification_template_3 =
        notification_template_fixture(%{
          category_ids: [category_id_1],
          product_ids: [product_id_1],
          part_ids: [part_id_1]
        })

      assert {:ok, [n3]} =
               NotificationTemplate.list(%{
                 category_ids: [category_id_1],
                 product_ids: [product_id_1],
                 part_ids: [part_id_1]
               })

      assert [n3.id] == [notification_template_3.id]
    end

    @tag :notification_template_resource
    test "NotificationTemplate.list/3 renders an error when applying as a filter
    an atom that does not exist" do
      assert {:error, %Ash.Error.Invalid{}} =
               NotificationTemplate.list(%{random_filter: [0]})
    end

    @tag :notification_template_resource
    test "NotificationTemplate.get/3 returns the notification_template with
    given id" do
      notification_template =
        notification_template_fixture()

      assert {:ok, n} = NotificationTemplate.get(notification_template.id)
      assert n.id == notification_template.id
    end

    @tag :notification_template_resource
    test "NotificationTemplate.create/2 with valid data creates a
    notification_template" do
      categories = create_categories()
      category_ids = create_category_ids(categories)

      products = create_products()
      product_ids = create_product_ids(products)

      parts = create_parts()
      part_ids = create_part_ids(parts)

      valid_attrs =
        notification_template_valid_attrs()
        |> Map.put(:category_ids, category_ids)
        |> Map.put(:product_ids, product_ids)
        |> Map.put(:part_ids, part_ids)

      assert {:ok, %NotificationTemplate{} = notification_template} =
               NotificationTemplate.create(valid_attrs)

      assert notification_template.categories[:id] == categories[:id]
      assert notification_template.products[:id] == products[:id]
      assert notification_template.parts[:id] == parts[:id]
      assert notification_template.name == valid_attrs.name
      assert notification_template.description == valid_attrs.description
      assert notification_template.title == valid_attrs.title
      assert notification_template.content == valid_attrs.content
      assert notification_template.condition == valid_attrs.condition
      assert notification_template.need_action == valid_attrs.need_action
      assert notification_template.draft == valid_attrs.draft
    end

    @tag :notification_template_resource
    test "NotificationTemplate.create/2 with invalid data returns error
    changeset" do
      assert {:error, %Ash.Error.Invalid{}} =
               NotificationTemplate.create(@invalid_attrs)
    end

    @tag :notification_template_resource
    test "NotificationTemplate.update/3 with valid data updates the
    notification_template" do
      categories = create_categories()
      category_ids = create_category_ids(categories)
      products = create_products()
      product_ids = create_product_ids(products)
      parts = create_parts()
      part_ids = create_part_ids(parts)

      notification_template =
        notification_template_fixture(%{
          category_ids: category_ids,
          product_ids: product_ids,
          part_ids: part_ids
        })

      new_categories = create_categories()
      new_category_ids = create_category_ids(new_categories)
      new_products = create_products()
      new_product_ids = create_product_ids(new_products)
      new_parts = create_parts()
      new_part_ids = create_part_ids(new_parts)

      update_attrs = %{
        category_ids: new_category_ids,
        product_ids: new_product_ids,
        part_ids: new_part_ids,
        name: "some updated name",
        description: "some updated description",
        title: "some updated title",
        content: "some updated content",
        condition: "some updated condition",
        need_action: true,
        draft: true
      }

      assert {:ok, %NotificationTemplate{} = notification_template} =
               NotificationTemplate.update(
                 notification_template,
                 update_attrs
               )

      assert notification_template.categories[:id] == new_categories[:id]
      assert notification_template.products[:id] == new_products[:id]
      assert notification_template.parts[:id] == new_parts[:id]
      assert notification_template.name == "some updated name"
      assert notification_template.description == "some updated description"
      assert notification_template.title == "some updated title"
      assert notification_template.content == "some updated content"
      assert notification_template.condition == "some updated condition"
      assert notification_template.need_action == true
      assert notification_template.draft == true
    end

    @tag :notification_template_resource
    test "NotificationTemplate.update/3 with invalid data returns error
    changeset" do
      notification_template =
        notification_template_fixture()

      assert {:error, %Ash.Error.Invalid{}} =
               NotificationTemplate.update(
                 notification_template,
                 @invalid_attrs
               )

      assert notification_template.name ==
               NotificationTemplate.get!(notification_template.id).name
    end

    @tag :notification_template_resource
    test "NotificationTemplate.delete/3 deletes the notification_template" do
      notification_template = notification_template_fixture()

      assert :ok == NotificationTemplate.delete(notification_template)

      assert_raise Ash.Error.Query.NotFound, fn ->
        NotificationTemplate.get!(notification_template.id)
      end
    end

    # NOTE: Do we need to create a code_interface like NotificationTemplate.change?
    @tag :notification_template_resource
    test "Ash.Changeset.new(notification_template) returns a
    notification_template changeset" do
      notification_template =
        notification_template_fixture()

      assert %Ash.Changeset{} = Ash.Changeset.new(notification_template)
    end
  end
end
