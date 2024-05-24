defmodule Prepair.AshDomains.Notifications do
  use Ash.Domain

  resources do
    resource Prepair.AshDomains.Notifications.NotificationTemplate
    resource Prepair.AshDomains.Notifications.CategoryNotificationTemplates
    resource Prepair.AshDomains.Notifications.ProductNotificationTemplates
    resource Prepair.AshDomains.Notifications.PartNotificationTemplates
  end
end
