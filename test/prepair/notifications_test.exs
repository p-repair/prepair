defmodule Prepair.NotificationsTest do
  use Prepair.DataCase

  alias Prepair.Notifications
  alias Prepair.Repo

  describe "notification_templates" do
    alias Prepair.Notifications.NotificationTemplate

    import Prepair.NotificationsFixtures
    import Prepair.ProductsFixtures

    @invalid_attrs %{
      name: nil,
      description: nil,
      title: nil,
      content: nil,
      condition: nil,
      need_action: nil,
      draft: nil
    }

    # A function helper to preload fields [:categories, :products, :parts].
    defp preload_notification_template_relations(notification_template) do
      notification_template |> Repo.preload([:categories, :products, :parts])
    end

    # It is needed to remove virtual fields to match on asserts of
    # list_notification_template/1 tests when we populate these fields.
    defp remove_virtual_fields(notification_template) do
      Notifications.get_notification_template!(notification_template.id)
      |> unload_notification_template_relations()
    end

    test "list_notification_templates/1 returns all notification_templates when
    no filters are passed" do
      notification_template =
        notification_template_fixture()
        |> unload_notification_template_relations()

      assert Notifications.list_notification_templates() == [
               notification_template
             ]
    end

    test "list_notification_templates/1 returns a list of notification_templates
     matching with :category_ids value" do
      category_1_id = category_fixture().id
      category_2_id = category_fixture().id

      notification_template_1 =
        notification_template_fixture(%{
          category_ids: [category_1_id, category_2_id]
        })
        |> remove_virtual_fields()

      notification_template_2 =
        notification_template_fixture(%{category_ids: [category_1_id]})
        |> remove_virtual_fields()

      _notification_template_3 =
        notification_template_fixture(%{category_ids: [category_2_id]})
        |> remove_virtual_fields()

      assert Notifications.list_notification_templates(
               category_ids: [category_1_id]
             ) ==
               [
                 notification_template_1,
                 notification_template_2
               ]
    end

    test "list_notification_templates/1 returns an empty list when
    :category_ids value is a list of ids that does not exists in the database" do
      assert Notifications.list_notification_templates(
               category_ids: [456, 457, 458]
             ) == []
    end

    test "list_notification_templates/1 returns a list of notification_templates
    matching with :product_ids value" do
      product_1_id = product_fixture().id
      product_2_id = product_fixture().id

      notification_template_1 =
        notification_template_fixture(%{
          product_ids: [product_1_id, product_2_id]
        })
        |> remove_virtual_fields()

      notification_template_2 =
        notification_template_fixture(%{product_ids: [product_1_id]})
        |> remove_virtual_fields()

      _notification_template_3 =
        notification_template_fixture(%{product_ids: [product_2_id]})
        |> remove_virtual_fields()

      assert Notifications.list_notification_templates(
               product_ids: [product_1_id]
             ) == [
               notification_template_1,
               notification_template_2
             ]
    end

    test "list_notification_templates/1 returns an empty list when :product_ids
    value is a list of ids that does not exists in the database" do
      assert Notifications.list_notification_templates(product_ids: [456]) == []
    end

    test "list_notification_templates/1 returns a list of notification_templates
     matching witch :part_ids value" do
      part_1_id = part_fixture().id
      part_2_id = part_fixture().id

      notification_template_1 =
        notification_template_fixture(%{
          part_ids: [part_1_id, part_2_id]
        })
        |> remove_virtual_fields()

      notification_template_2 =
        notification_template_fixture(%{part_ids: [part_1_id]})
        |> remove_virtual_fields()

      _notification_template_3 =
        notification_template_fixture(%{part_ids: [part_2_id]})
        |> remove_virtual_fields()

      assert Notifications.list_notification_templates(part_ids: [part_1_id]) ==
               [
                 notification_template_1,
                 notification_template_2
               ]
    end

    test "list_notification_templates/1 returns an empty list when :part_ids
    value is a list of ids that does not exists in the database" do
      assert Notifications.list_notification_templates(part_ids: [456]) == []
    end

    test "list_notification_templates/1 filters can be combined: returns an
    empty list if :category_ids value is a list of ids which don’t exist in the
    database" do
      product_1_id = product_fixture().id

      _notification_template_1 =
        notification_template_fixture(%{product_ids: [product_1_id]})

      assert Notifications.list_notification_templates(
               category_ids: [456],
               product_ids: [product_1_id]
             ) == []
    end

    test "list_notification_templates/1 filters can be combined: returns an
    empty list if :product_ids value is a list of ids which don’t exist in the
    database" do
      category_id_1 = category_fixture().id

      _notification_template_1 =
        notification_template_fixture(%{category_ids: [category_id_1]})

      assert Notifications.list_notification_templates(
               category_ids: [category_id_1],
               product_ids: [456]
             ) == []
    end

    test "list_notification_templates/1 filters can be combined: returns an
    empty list if :part_ids value is a list of ids which don’t exist in the
    database" do
      category_id_1 = category_fixture().id

      _notification_template_1 =
        notification_template_fixture(%{category_ids: [category_id_1]})

      assert Notifications.list_notification_templates(
               category_ids: [category_id_1],
               part_ids: [456]
             ) == []
    end

    test "list_notification_templates/1 filters can be combined: returns an
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

      assert Notifications.list_notification_templates(
               category_ids: [category_id_1],
               product_ids: [product_id_1],
               part_ids: [part_id_1]
             ) ==
               []
    end

    test "list_notification_templates/1 filters can be combined: returns
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
        |> remove_virtual_fields()

      assert Notifications.list_notification_templates(
               category_ids: [category_id_1],
               product_ids: [product_id_1],
               part_ids: [part_id_1]
             ) == [notification_template_3]
    end

    test "list_notification_templates/1 raises when applying as a filter which
    does not exist" do
      assert_raise FunctionClauseError, fn ->
        Notifications.list_notification_templates(random_filter: [0])
      end
    end

    test "get_notification_template!/1 returns the notification_template with given id" do
      notification_template =
        notification_template_fixture()
        |> preload_notification_template_relations()

      assert Notifications.get_notification_template!(notification_template.id) ==
               notification_template
    end

    test "create_notification_template/1 with valid data creates a notification_template" do
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
               Notifications.create_notification_template(valid_attrs)

      assert notification_template.categories == categories
      assert notification_template.products == products
      assert notification_template.parts == parts
      assert notification_template.name == valid_attrs.name
      assert notification_template.description == valid_attrs.description
      assert notification_template.title == valid_attrs.title
      assert notification_template.content == valid_attrs.content
      assert notification_template.condition == valid_attrs.condition
      assert notification_template.need_action == valid_attrs.need_action
      assert notification_template.draft == valid_attrs.draft
    end

    test "create_notification_template/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Notifications.create_notification_template(@invalid_attrs)
    end

    test "update_notification_template/2 with valid data updates the notification_template" do
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
        |> preload_notification_template_relations()

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
               Notifications.update_notification_template(
                 notification_template,
                 update_attrs
               )

      assert notification_template.categories == new_categories
      assert notification_template.products == new_products
      assert notification_template.parts == new_parts
      assert notification_template.name == "some updated name"
      assert notification_template.description == "some updated description"
      assert notification_template.title == "some updated title"
      assert notification_template.content == "some updated content"
      assert notification_template.condition == "some updated condition"
      assert notification_template.need_action == true
      assert notification_template.draft == true
    end

    test "update_notification_template/2 with invalid data returns error changeset" do
      notification_template =
        notification_template_fixture()
        |> preload_notification_template_relations()

      assert {:error, %Ecto.Changeset{}} =
               Notifications.update_notification_template(
                 notification_template,
                 @invalid_attrs
               )

      assert notification_template ==
               Notifications.get_notification_template!(
                 notification_template.id
               )
               |> preload_notification_template_relations()
    end

    test "delete_notification_template/1 deletes the notification_template" do
      notification_template = notification_template_fixture()

      assert {:ok, %NotificationTemplate{}} =
               Notifications.delete_notification_template(notification_template)

      assert_raise Ecto.NoResultsError, fn ->
        Notifications.get_notification_template!(notification_template.id)
      end
    end

    test "change_notification_template/1 returns a notification_template changeset" do
      notification_template =
        notification_template_fixture()
        |> preload_notification_template_relations()

      assert %Ecto.Changeset{} =
               Notifications.change_notification_template(notification_template)
    end
  end
end
