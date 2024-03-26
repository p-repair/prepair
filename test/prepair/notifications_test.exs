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

    @random_uuid_1 Ecto.UUID.generate()
    @random_uuid_2 Ecto.UUID.generate()
    @random_uuid_3 Ecto.UUID.generate()

    # A function helper to preload fields [:categories, :products, :parts].
    defp preload_notification_template_relations(notification_template) do
      notification_template |> Repo.preload([:categories, :products, :parts])
    end

    # It is needed to remove virtual fields to match on asserts of
    # list_notification_template/1 tests when we populate these fields.
    defp remove_virtual_fields(notification_template) do
      Notifications.get_notification_template!(notification_template.uuid)
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
     matching with :category_uuids value" do
      category_1_uuid = category_fixture().uuid
      category_2_uuid = category_fixture().uuid

      notification_template_1 =
        notification_template_fixture(%{
          category_uuids: [category_1_uuid, category_2_uuid]
        })
        |> remove_virtual_fields()

      notification_template_2 =
        notification_template_fixture(%{category_uuids: [category_1_uuid]})
        |> remove_virtual_fields()

      _notification_template_3 =
        notification_template_fixture(%{category_uuids: [category_2_uuid]})
        |> remove_virtual_fields()

      assert Notifications.list_notification_templates(
               category_uuids: [category_1_uuid]
             ) ==
               [
                 notification_template_1,
                 notification_template_2
               ]
    end

    test "list_notification_templates/1 returns an empty list when
    :category_uuids value is a list of uuids that does not exists in the database" do
      assert Notifications.list_notification_templates(
               category_uuids: [@random_uuid_1, @random_uuid_2, @random_uuid_3]
             ) == []
    end

    test "list_notification_templates/1 returns a list of notification_templates
    matching with :product_uuids value" do
      product_1_uuid = product_fixture().uuid
      product_2_uuid = product_fixture().uuid

      notification_template_1 =
        notification_template_fixture(%{
          product_uuids: [product_1_uuid, product_2_uuid]
        })
        |> remove_virtual_fields()

      notification_template_2 =
        notification_template_fixture(%{product_uuids: [product_1_uuid]})
        |> remove_virtual_fields()

      _notification_template_3 =
        notification_template_fixture(%{product_uuids: [product_2_uuid]})
        |> remove_virtual_fields()

      assert Notifications.list_notification_templates(
               product_uuids: [product_1_uuid]
             ) == [
               notification_template_1,
               notification_template_2
             ]
    end

    test "list_notification_templates/1 returns an empty list when :product_uuids
    value is a list of uuids that does not exists in the database" do
      assert Notifications.list_notification_templates(
               product_uuids: [@random_uuid_1]
             ) ==
               []
    end

    test "list_notification_templates/1 returns a list of notification_templates
     matching witch :part_uuids value" do
      part_1_uuid = part_fixture().uuid
      part_2_uuid = part_fixture().uuid

      notification_template_1 =
        notification_template_fixture(%{
          part_uuids: [part_1_uuid, part_2_uuid]
        })
        |> remove_virtual_fields()

      notification_template_2 =
        notification_template_fixture(%{part_uuids: [part_1_uuid]})
        |> remove_virtual_fields()

      _notification_template_3 =
        notification_template_fixture(%{part_uuids: [part_2_uuid]})
        |> remove_virtual_fields()

      assert Notifications.list_notification_templates(
               part_uuids: [part_1_uuid]
             ) ==
               [
                 notification_template_1,
                 notification_template_2
               ]
    end

    test "list_notification_templates/1 returns an empty list when :part_uuids
    value is a list of uuids that does not exists in the database" do
      assert Notifications.list_notification_templates(
               part_uuids: [@random_uuid_1]
             ) ==
               []
    end

    test "list_notification_templates/1 filters can be combined: returns an
    empty list if :category_uuids value is a list of uuids which don’t exist in the
    database" do
      product_1_uuid = product_fixture().uuid

      _notification_template_1 =
        notification_template_fixture(%{product_uuids: [product_1_uuid]})

      assert Notifications.list_notification_templates(
               category_uuids: [@random_uuid_1],
               product_uuids: [product_1_uuid]
             ) == []
    end

    test "list_notification_templates/1 filters can be combined: returns an
    empty list if :product_uuids value is a list of uuids which don’t exist in the
    database" do
      category_uuid_1 = category_fixture().uuid

      _notification_template_1 =
        notification_template_fixture(%{category_uuids: [category_uuid_1]})

      assert Notifications.list_notification_templates(
               category_uuids: [category_uuid_1],
               product_uuids: [@random_uuid_1]
             ) == []
    end

    test "list_notification_templates/1 filters can be combined: returns an
    empty list if :part_uuids value is a list of uuids which don’t exist in the
    database" do
      category_uuid_1 = category_fixture().uuid

      _notification_template_1 =
        notification_template_fixture(%{category_uuids: [category_uuid_1]})

      assert Notifications.list_notification_templates(
               category_uuids: [category_uuid_1],
               part_uuids: [@random_uuid_1]
             ) == []
    end

    test "list_notification_templates/1 filters can be combined: returns an
    empty list if :category_uuids, :product_uuids and :part_uuids values are lists of
    uuids which don’t match on the same notification_templates" do
      category_uuid_1 = category_fixture().uuid
      product_uuid_1 = product_fixture().uuid
      part_uuid_1 = part_fixture().uuid

      _notification_template_1 =
        notification_template_fixture(%{category_uuids: [category_uuid_1]})

      _notification_template_2 =
        notification_template_fixture(%{product_uuids: [product_uuid_1]})

      _notification_template_3 =
        notification_template_fixture(%{part_uuids: [part_uuid_1]})

      assert Notifications.list_notification_templates(
               category_uuids: [category_uuid_1],
               product_uuids: [product_uuid_1],
               part_uuids: [part_uuid_1]
             ) ==
               []
    end

    test "list_notification_templates/1 filters can be combined: returns
    matching notification_templates with :category_uuids, :product_uuids and
    :part_uuids when all are set" do
      category_uuid_1 = category_fixture().uuid
      product_uuid_1 = product_fixture().uuid
      part_uuid_1 = part_fixture().uuid

      _notification_template_1 =
        notification_template_fixture(%{category_uuids: [category_uuid_1]})

      _notification_template_2 =
        notification_template_fixture(%{
          category_uuids: [category_uuid_1],
          product_uuids: [product_uuid_1]
        })

      notification_template_3 =
        notification_template_fixture(%{
          category_uuids: [category_uuid_1],
          product_uuids: [product_uuid_1],
          part_uuids: [part_uuid_1]
        })
        |> remove_virtual_fields()

      assert Notifications.list_notification_templates(
               category_uuids: [category_uuid_1],
               product_uuids: [product_uuid_1],
               part_uuids: [part_uuid_1]
             ) == [notification_template_3]
    end

    test "list_notification_templates/1 raises when applying as a filter which
    does not exist" do
      assert_raise FunctionClauseError, fn ->
        Notifications.list_notification_templates(random_filter: [0])
      end
    end

    test "get_notification_template!/1 returns the notification_template with given uuid" do
      notification_template =
        notification_template_fixture()
        |> preload_notification_template_relations()

      assert Notifications.get_notification_template!(
               notification_template.uuid
             ) ==
               notification_template
    end

    test "create_notification_template/1 with valid data creates a notification_template" do
      categories = create_categories()
      category_uuids = create_category_uuids(categories)

      products = create_products()
      product_uuids = create_product_uuids(products)

      parts = create_parts()
      part_uuids = create_part_uuids(parts)

      valid_attrs =
        notification_template_valid_attrs()
        |> Map.put(:category_uuids, category_uuids)
        |> Map.put(:product_uuids, product_uuids)
        |> Map.put(:part_uuids, part_uuids)

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
      category_uuids = create_category_uuids(categories)
      products = create_products()
      product_uuids = create_product_uuids(products)
      parts = create_parts()
      part_uuids = create_part_uuids(parts)

      notification_template =
        notification_template_fixture(%{
          category_uuids: category_uuids,
          product_uuids: product_uuids,
          part_uuids: part_uuids
        })
        |> preload_notification_template_relations()

      new_categories = create_categories()
      new_category_uuids = create_category_uuids(new_categories)
      new_products = create_products()
      new_product_uuids = create_product_uuids(new_products)
      new_parts = create_parts()
      new_part_uuids = create_part_uuids(new_parts)

      update_attrs = %{
        category_uuids: new_category_uuids,
        product_uuids: new_product_uuids,
        part_uuids: new_part_uuids,
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
                 notification_template.uuid
               )
               |> preload_notification_template_relations()
    end

    test "delete_notification_template/1 deletes the notification_template" do
      notification_template = notification_template_fixture()

      assert {:ok, %NotificationTemplate{}} =
               Notifications.delete_notification_template(notification_template)

      assert_raise Ecto.NoResultsError, fn ->
        Notifications.get_notification_template!(notification_template.uuid)
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
