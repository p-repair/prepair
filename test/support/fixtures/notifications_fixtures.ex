defmodule Prepair.LegacyContexts.NotificationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Prepair.LegacyContexts.Notifications` context.
  """

  alias Prepair.AshDomains.Notifications.NotificationTemplate

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
      |> NotificationTemplate.create()

    notification_template
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
  end

  def create_notification_template_ids(notification_templates),
    do: notification_templates |> Enum.map(fn x -> x.id end)
end
