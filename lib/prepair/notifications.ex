defmodule Prepair.Notifications do
  @moduledoc """
  The Notifications context.
  """

  import Ecto.Query, warn: false
  alias Prepair.Repo

  alias Prepair.Notifications.NotificationTemplate
  alias Prepair.Products

  @doc """
  Returns a list of notification templates.

  ## Options

  *`:category_uuids`, `:product_uuids`, `:part_uuids`  - Takes a list of category,
  product and/or part uuids, and returns notification templates matching
  on these uuids.

  **Note:** Several options can be combined to filter results.

  **Note:** Invalid filters should be ignored on web and controllers,
  otherwise it will raise an Ecto.QueryError.

  **Note:** Authorized filters should be validated on web and controllers,
  otherwise it would be possible for anyone to filter from all other product
  fields.

  ## Examples

      iex> list_notification_templates()
      [%NotificationTemplate{uuid: 123, …}, %NotificationTemplate{…}, ...]

      iex> list_notification_templates(
        product_uuids: ["4a50cd21-1181-47d5-831a-113c430abeeb"]
            )
      [%NotificationTemplate{
        uuid: …,
        name: …,
        product_uuid: "4a50cd21-1181-47d5-831a-113c430abeeb",
        …
        },
      ...]

      iex> list_notification_templates(
        category_uuids: ["aa6e10c2-a3a0-41c5-8cee-3597e165cd4e"],
        product_uuids: ["4a50cd21-1181-47d5-831a-113c430abeeb"]
            )
      [%NotificationTemplate{
        uuid: …,
        name: …,
        category_uuid: "aa6e10c2-a3a0-41c5-8cee-3597e165cd4e",
        product_uuid: "4a50cd21-1181-47d5-831a-113c430abeeb"
        }]

      iex> list_notification_templates(
        product_uuids: ["4a50cd21-1181-47d5-831a-113c430abeeb],
        category_uuids: ["aa6e10c2-a3a0-41c5-8cee-3597e165cd4e"],
        part_uuids: ["04811971-da44-4d7d-a805-74422166fdbe"]
            )
      []

      iex> list_products(random_filter: ["random value"])
      ** (Ecto.QueryError) lib/prepair/notifications.ex:51: field `random_filter` in
      `where` does not exist in schema
      Prepair.Notifications.NotificationTemplates in query:
      ...
  """
  def list_notification_templates(filters \\ []) do
    Enum.reduce(filters, NotificationTemplate, &filter/2)
    |> Repo.all()
  end

  def filter({:category_uuids, uuids}, query)
      when is_list(uuids) do
    uuids = uuids |> normalise_uuids()

    query
    |> join(:inner, [n], c in "category_notification_templates",
      as: :category_notification_templates,
      on: n.uuid == c.notification_template_uuid
    )
    |> where([n, category_notification_templates: c], c.category_uuid in ^uuids)
  end

  def filter({:product_uuids, uuids}, query)
      when is_list(uuids) do
    uuids = uuids |> normalise_uuids()

    query
    |> join(:inner, [n], p in "product_notification_templates",
      as: :product_notification_templates,
      on: n.uuid == p.notification_template_uuid
    )
    |> where(
      [n, product_notification_templates: p],
      p.product_uuid in ^uuids
    )
  end

  def filter({:part_uuids, uuids}, query) when is_list(uuids) do
    uuids = uuids |> normalise_uuids()

    query
    |> join(:inner, [n], p in "part_notification_templates",
      as: :part_notification_templates,
      on: n.uuid == p.notification_template_uuid
    )
    |> where([n, part_notification_templates: p], p.part_uuid in ^uuids)
  end

  ## Helper function to normalise UUIDs sent to the database query.
  defp normalise_uuids(uuids) do
    uuids
    |> Enum.map(fn uuid ->
      with {:ok, dumped} <- Ecto.UUID.dump(uuid) do
        dumped
      else
        :error -> uuid
      end
    end)
  end

  @doc """
  Returns a list of notification templates based on the provided list of uuids.

  ## Examples

      iex> list_notification_templates_by_uuid()
      []

      iex> list_notification_templates_by_uuid(
        ["e9b4579f-c4d1-4924-83e8-229ebb44cc3b"]
            )
      [
        %NotificationTemplate{
          uuid: "e9b4579f-c4d1-4924-83e8-229ebb44cc3b",
          name: …
         },
      ]

  """
  def list_notification_templates_by_uuid(nil), do: []

  def list_notification_templates_by_uuid(notification_template_uuids)
      when is_list(notification_template_uuids) and
             notification_template_uuids != [] do
    Repo.all(
      from n in NotificationTemplate,
        where: n.uuid in ^notification_template_uuids
    )
  end

  @doc """
  Gets a single notification_template.

  Raises `Ecto.NoResultsError` if the Notification template does not exist.

  ## Examples

      iex> get_notification_template!("d080e457-b29f-4b55-8cdf-8c0cf462e739")
      %NotificationTemplate{}

      iex> get_notification_template!("0f3b9817-6433-409c-823d-7d1f1083430c")
      ** (Ecto.NoResultsError)

  """
  def get_notification_template!(uuid) do
    NotificationTemplate
    |> Repo.get!(uuid)
    |> Repo.preload([:categories, :parts, :products])
  end

  @doc """
  Creates a notification_template.

  ## Examples

      iex> create_notification_template(%{field: value})
      {:ok, %NotificationTemplate{}}

      iex> create_notification_template(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_notification_template(attrs \\ %{}) do
    %NotificationTemplate{}
    |> change_notification_template(attrs)
    |> Repo.insert(returning: [:uuid])
  end

  @doc """
  Updates a notification_template.

  ## Examples

      iex> update_notification_template(notification_template, %{field: new_value})
      {:ok, %NotificationTemplate{}}

      iex> update_notification_template(notification_template, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_notification_template(
        %NotificationTemplate{} = notification_template,
        attrs
      ) do
    notification_template
    |> change_notification_template(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a notification_template.

  ## Examples

      iex> delete_notification_template(notification_template)
      {:ok, %NotificationTemplate{}}

      iex> delete_notification_template(notification_template)
      {:error, %Ecto.Changeset{}}

  """
  def delete_notification_template(
        %NotificationTemplate{} = notification_template
      ) do
    Repo.delete(notification_template)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking notification_template changes.

  ## Examples

      iex> change_notification_template(notification_template)
      %Ecto.Changeset{data: %NotificationTemplate{}}

  """
  def change_notification_template(
        %NotificationTemplate{} = notification_template,
        attrs \\ %{}
      ) do
    categories = Products.list_categories_by_uuid(attrs[:category_uuids])
    products = Products.list_products_by_uuid(attrs[:product_uuids])
    parts = Products.list_parts_by_uuid(attrs[:part_uuids])

    notification_template
    |> NotificationTemplate.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:categories, categories)
    |> Ecto.Changeset.put_assoc(:products, products)
    |> Ecto.Changeset.put_assoc(:parts, parts)
  end
end
