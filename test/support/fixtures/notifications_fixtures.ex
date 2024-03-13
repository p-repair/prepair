defmodule Prepair.NotificationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Prepair.Notifications` context.
  """

  @doc """
  Generate a unique notification_template name.
  """
  def unique_notification_template_name,
    do: "some name#{System.unique_integer([:positive])}"

  @doc """
  Generate a notification_template.
  """
  def notification_template_fixture(attrs \\ %{}) do
    {:ok, notification_template} =
      attrs
      |> Enum.into(notification_template_valid_attrs())
      |> Prepair.Notifications.create_notification_template()

    notification_template
    |> unload_notification_template_relations()
  end

  def notification_template_valid_attrs() do
    %{
      name: unique_notification_template_name(),
      description: "some description",
      title: "some title",
      content: "some content",
      condition: "some condition",
      need_action: false,
      draft: false
    }
  end

  def create_notification_templates() do
    [notification_template_fixture(), notification_template_fixture()]
    |> Enum.map(&unload_notification_template_relations/1)
  end

  def create_notification_template_ids(notification_templates),
    do: notification_templates |> Enum.map(fn x -> x.id end)

  @doc """
  A helper function to unload notification template relations.
  """
  def unload_notification_template_relations(notification_template) do
    notification_template
    |> Prepair.DataCase.unload(:categories, :many)
    |> Prepair.DataCase.unload(:products, :many)
    |> Prepair.DataCase.unload(:parts, :many)
  end
end
