defmodule Prepair.Products do
  @moduledoc """
  The Products context.
  """

  import Ecto.Query, warn: false
  alias Prepair.Notifications
  alias Prepair.Products.{Manufacturer, Category, Part, Product}
  alias Prepair.Repo

  @doc """
  Returns the list of manufacturers.

  ## Examples

      iex> list_manufacturers()
      [%Manufacturer{}, ...]

  """
  def list_manufacturers() do
    Repo.all(Manufacturer)
  end

  @doc """
  Gets a single manufacturer.

  Raises `Ecto.NoResultsError` if the Manufacturer does not exist.

  ## Examples

      iex> get_manufacturer!("d080e457-b29f-4b55-8cdf-8c0cf462e739")
      %Manufacturer{}

      iex> get_manufacturer!("0f3b9817-6433-409c-823d-7d1f1083430c")
      ** (Ecto.NoResultsError)

  """
  def get_manufacturer!(id), do: Repo.get!(Manufacturer, id)

  @doc """
  Creates a manufacturer.

  ## Examples

      iex> create_manufacturer(%{field: value})
      {:ok, %Manufacturer{}}

      iex> create_manufacturer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_manufacturer(attrs \\ %{}) do
    %Manufacturer{}
    |> Manufacturer.changeset(attrs)
    |> Repo.insert(returning: [:id])
  end

  @doc """
  Updates a manufacturer.

  ## Examples

      iex> update_manufacturer(manufacturer, %{field: new_value})
      {:ok, %Manufacturer{}}

      iex> update_manufacturer(manufacturer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_manufacturer(%Manufacturer{} = manufacturer, attrs) do
    manufacturer
    |> Manufacturer.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a manufacturer.

  ## Examples

      iex> delete_manufacturer(manufacturer)
      {:ok, %Manufacturer{}}

      iex> delete_manufacturer(manufacturer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_manufacturer(%Manufacturer{} = manufacturer) do
    Repo.delete(manufacturer)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking manufacturer changes.

  ## Examples

      iex> change_manufacturer(manufacturer)
      %Ecto.Changeset{data: %Manufacturer{}}

  """
  def change_manufacturer(%Manufacturer{} = manufacturer, attrs \\ %{}) do
    Manufacturer.changeset(manufacturer, attrs)
  end

  alias Prepair.Products.Category

  @doc """
  Returns the list of categories.

  ## Examples

      iex> list_categories()
      [%Category{}, ...]

  """
  def list_categories() do
    Repo.all(Category)
  end

  @doc """
  Returns a list of categories based on the provided list of ids.

  ## Examples

      iex> list_catgories_by_id()
      []

      iex> list_categories_by_id(["4a50cd21-1181-47d5-831a-113c430abeeb", …])
      [%Category{id: "4a50cd21-1181-47d5-831a-113c430abeeb", name: …},
      %Category{id: …, name: …}, ...]

  """
  def list_categories_by_id(nil), do: []

  def list_categories_by_id(category_ids)
      when is_list(category_ids) and category_ids != [] do
    Repo.all(from c in Category, where: c.id in ^category_ids)
  end

  @doc """
  Gets a single category.

  Raises `Ecto.NoResultsError` if the Category does not exist.

  ## Examples

      iex> get_category!("d080e457-b29f-4b55-8cdf-8c0cf462e739")
      %Category{}

      iex> get_category!("0f3b9817-6433-409c-823d-7d1f1083430c")
      ** (Ecto.NoResultsError)

  """
  def get_category!(id) do
    Category
    |> Repo.get!(id)
    |> Repo.preload(:notification_templates)
  end

  @doc """
  Creates a category.

  ## Examples

      iex> create_category(%{field: value})
      {:ok, %Category{}}

      iex> create_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_category(attrs \\ %{}) do
    %Category{}
    |> change_category(attrs)
    |> Repo.insert(returning: [:id])
  end

  @doc """
  Updates a category.

  ## Examples

      iex> update_category(category, %{field: new_value})
      {:ok, %Category{}}

      iex> update_category(category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_category(%Category{} = category, attrs) do
    category
    |> change_category(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a category.

  ## Examples

      iex> delete_category(category)
      {:ok, %Category{}}

      iex> delete_category(category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category changes.

  ## Examples

      iex> change_category(category)
      %Ecto.Changeset{data: %Category{}}

  """
  def change_category(%Category{} = category, attrs \\ %{}) do
    notification_templates =
      Notifications.list_notification_templates_by_id(
        attrs[:notification_template_ids]
      )

    category
    |> Category.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:notification_templates, notification_templates)
  end

  alias Prepair.Products.Product

  @doc """
  Returns the list of products.

  ## Options

  *`:product_ids` - Takes a list of product ids, and returns products matching
  on these ids.

  *`:category_id` - Takes a list of category ids, and returns products matching
  on these ids.

  *`:manufacturer_id` - Takes a list of manufacturer ids, and returns products
  matching on these ids.

  **Note:** Several options can be combined to filter results.

  **Note:** Invalid filters should be ignored on web and controllers,
  otherwise it will raise an Ecto.QueryError.

  **Note:** Authorized filters should be validated on web and controllers,
  otherwise it would be possible for anyone to filter from all other product
  fields.

  ## Examples

      iex> list_products()
      [
        %Product{id: "4a50cd21-1181-47d5-831a-113c430abeeb", name: …},
        %Product{id: "0b012a6c-89a7-416c-b1ec-4e9a71252b0f", name: …},
        ...
      ]

      iex> list_products(product_ids: ["4a50cd21-1181-47d5-831a-113c430abeeb"])
      [%Product{id: "4a50cd21-1181-47d5-831a-113c430abeeb", name: …}]

      iex> list_products(category_id: ["aa6e10c2-a3a0-41c5-8cee-3597e165cd4e"])
      [%Product{id: …, category_id: "aa6e10c2-a3a0-41c5-8cee-3597e165cd4e", …}]

      iex> list_products(manufacturer_id: ["04811971-da44-4d7d-a805-74422166fdbe"])
      [%Product{id: …, manufacturer_id: "04811971-da44-4d7d-a805-74422166fdbe", …}]

      iex> list_products(
        category_id: ["aa6e10c2-a3a0-41c5-8cee-3597e165cd4e"],
        manufacturer_id: ["04811971-da44-4d7d-a805-74422166fdbe"]
            )
      [%Product{
        id: …,
        name: …,
        category_id: "aa6e10c2-a3a0-41c5-8cee-3597e165cd4e",
        manufacturer_id: "04811971-da44-4d7d-a805-74422166fdbe"
          }]

      iex> list_products(
        product_ids: ["4a50cd21-1181-47d5-831a-113c430abeeb"],
        category_id: ["aa6e10c2-a3a0-41c5-8cee-3597e165cd4e"],
        manufacturer_id: ["04811971-da44-4d7d-a805-74422166fdbe"]
            )
      []

      iex> list_products(random_filter: ["random value"])
      ** (Ecto.QueryError) lib/prepair/products.ex:304: field `random_filter` in
      `where` does not exist in schema Prepair.Products.Product in query:
      ...
  """
  def list_products(filters \\ []) do
    Enum.reduce(filters, Product, &filter/2)
    |> Repo.all()
  end

  defp filter({_k, [""]}, query) do
    query
  end

  defp filter({:product_ids, product_ids}, query)
       when is_list(product_ids) do
    query |> where([p], p.id in ^product_ids)
  end

  defp filter({_k, []}, query) do
    query
  end

  defp filter({k, v}, query) when is_list(v) do
    query |> where([p], field(p, ^k) in ^v)
  end

  @doc """
  Returns a list of products based on the provided list of ids.

  ## Examples

      iex> list_products_by_ids()
      []

      iex> list_products_by_ids(
        product_ids: ["4a50cd21-1181-47d5-831a-113c430abeeb"]
            )
      [%Product{id: "4a50cd21-1181-47d5-831a-113c430abeeb", name: …}]

  """
  def list_products_by_id(nil), do: []

  def list_products_by_id(product_ids)
      when is_list(product_ids) and product_ids != [] do
    Repo.all(from p in Product, where: p.id in ^product_ids)
  end

  @doc """
  Gets a single product.

  Raises `Ecto.NoResultsError` if the Product does not exist.

  ## Examples

      iex> get_product!("d080e457-b29f-4b55-8cdf-8c0cf462e739")
      %Product{}

      iex> get_product!("0f3b9817-6433-409c-823d-7d1f1083430c")
      ** (Ecto.NoResultsError)

  """
  def get_product!(id) do
    Product
    |> Repo.get!(id)
    |> Repo.preload([:category, :manufacturer, :parts, :notification_templates])
  end

  @doc """
  Creates a product.

  ## Examples

      iex> create_product(%{field: value})
      {:ok, %Product{}}

      iex> create_product(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_product(attrs \\ %{}) do
    %Product{}
    |> change_product(attrs)
    |> Repo.insert(returning: [:id])
  end

  @doc """
  Updates a product.

  ## Examples

      iex> update_product(product, %{field: new_value})
      {:ok, %Product{}}

      iex> update_product(product, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_product(%Product{} = product, attrs) do
    product
    |> change_product(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a product.

  ## Examples

      iex> delete_product(product)
      {:ok, %Product{}}

      iex> delete_product(product)
      {:error, %Ecto.Changeset{}}

  """
  def delete_product(%Product{} = product) do
    Repo.delete(product)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking product changes.

  ## Examples

      iex> change_product(product)
      %Ecto.Changeset{data: %Product{}}

  """
  def change_product(%Product{} = product, attrs \\ %{}) do
    parts = list_parts_by_id(attrs[:part_ids])

    notification_templates =
      Notifications.list_notification_templates_by_id(
        attrs[:notification_template_ids]
      )

    product
    |> Product.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:parts, parts)
    |> Ecto.Changeset.put_assoc(:notification_templates, notification_templates)
  end

  alias Prepair.Products.Part

  @doc """
  Returns the list of parts.

  ## Examples

      iex> list_parts()
      [%Part{}, ...]

  """
  def list_parts() do
    Repo.all(Part)
  end

  @doc """
  Returns a list of parts based on the provided list of ids.

  ## Examples

      iex> list_parts_by_id()
      []

      iex> list_parts_by_id(
        part_ids: ["4a50cd21-1181-47d5-831a-113c430abeeb"]
            )
      [%Part{id: "4a50cd21-1181-47d5-831a-113c430abeeb", name: …}]

  """
  def list_parts_by_id(nil), do: []

  def list_parts_by_id(part_ids)
      when is_list(part_ids) and part_ids != [] do
    Repo.all(from p in Part, where: p.id in ^part_ids)
  end

  @doc """
  Gets a single part.

  Raises `Ecto.NoResultsError` if the Part does not exist.

  ## Examples

      iex> get_part!("d080e457-b29f-4b55-8cdf-8c0cf462e739")
      %Part{}

      iex> get_part!("0f3b9817-6433-409c-823d-7d1f1083430c")
      ** (Ecto.NoResultsError)

  """
  def get_part!(id) do
    Part
    |> Repo.get!(id)
    |> Repo.preload([
      :category,
      :manufacturer,
      :products,
      :notification_templates
    ])
  end

  @doc """
  Creates a part.

  ## Examples

      iex> create_part(%{field: value})
      {:ok, %Part{}}

      iex> create_part(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_part(attrs \\ %{}) do
    %Part{}
    |> change_part(attrs)
    |> Repo.insert(returning: [:id])
  end

  @doc """
  Updates a part.

  ## Examples

      iex> update_part(part, %{field: new_value})
      {:ok, %Part{}}

      iex> update_part(part, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_part(%Part{} = part, attrs) do
    part
    |> change_part(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a part.

  ## Examples

      iex> delete_part(part)
      {:ok, %Part{}}

      iex> delete_part(part)
      {:error, %Ecto.Changeset{}}

  """
  def delete_part(%Part{} = part) do
    Repo.delete(part)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking part changes.

  ## Examples

      iex> change_part(part)
      %Ecto.Changeset{data: %Part{}}

  """
  def change_part(%Part{} = part, attrs \\ %{}) do
    products = list_products_by_id(attrs[:product_ids])

    notification_templates =
      Notifications.list_notification_templates_by_id(
        attrs[:notification_template_ids]
      )

    part
    |> Part.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:products, products)
    |> Ecto.Changeset.put_assoc(:notification_templates, notification_templates)
  end
end
