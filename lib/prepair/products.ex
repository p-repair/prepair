defmodule Prepair.Products do
  @moduledoc """
  The Products context.
  """

  import Ecto.Query, warn: false
  alias Prepair.Repo

  alias Prepair.Products.{Manufacturer, Category, Part, Product}

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

      iex> get_manufacturer!(123)
      %Manufacturer{}

      iex> get_manufacturer!(456)
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
    |> Repo.insert()
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
  Gets a single category.

  Raises `Ecto.NoResultsError` if the Category does not exist.

  ## Examples

      iex> get_category!(123)
      %Category{}

      iex> get_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_category!(id), do: Repo.get!(Category, id)

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
    |> Category.changeset(attrs)
    |> Repo.insert()
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
    |> Category.changeset(attrs)
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
    Category.changeset(category, attrs)
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
      [%Product{id: 123, name: …}, %Product{id: 124, name: …}, ...]

      iex> list_products(product_ids: [123, 124])
      [%Product{id: 123, name: …}, %Product{id: 124, name: …}, ...]

      iex> list_products(category_id: [1])
      [%Product{id: 222, name: …, category_id: 1, …}, %Product{id: …}, ...]

      iex> list_products(manufacturer_id: [1])
      [%Product{id: 223, name: …, manufacturer_id: 1, …}, %Product{id: …}, ...]

      iex> list_products(category_id: [1], manufacturer_id: [1])
      [%Product{id: 300, name: …, category_id: 1, manufacturer_id: …}]

      iex> list_products(product_ids: [123], category_id: [1],
        manufacturer_id: [1])
      []

      iex> list_products(random_filter: [1])
      ** (Ecto.QueryError) lib/prepair/products.ex:304: field `random_filter` in
      `where` does not exist in schema Prepair.Products.Product in query:
      ...
  """
  def list_products(filters \\ []) do
    Enum.reduce(filters, Product, &filter/2)
    |> Repo.all()
  end

  defp filter({_k, ["select"]}, query) do
    query
  end

  defp filter({:product_ids, product_ids}, query) when is_list(product_ids) do
    query |> where([p], p.id in ^product_ids)
  end

  defp filter({_k, []}, query) do
    query
  end

  defp filter({k, v}, query) when is_list(v) do
    query |> where([p], field(p, ^k) in ^v)
  end

  @doc """
  Returns the list of products based on a list of ids.

  ## Examples

      iex> list_products_by_ids()
      []

      iex> list_products_by_ids([123, 124, 137, 140])
      [%Product{id: 123, name: …}, %Product{id: 124, name: …}, ...]

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

      iex> get_product!(123)
      %Product{}

      iex> get_product!(456)
      ** (Ecto.NoResultsError)

  """
  def get_product!(id) do
    Product
    |> Repo.get!(id)
    |> Repo.preload([:category, :manufacturer, :parts])
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
    |> Repo.insert()
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

    product
    |> Product.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:parts, parts)
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
  Returns the list of parts based on a list of ids.
  """
  def list_parts_by_id(nil), do: []

  def list_parts_by_id(part_ids) when is_list(part_ids) and part_ids != [] do
    Repo.all(from p in Part, where: p.id in ^part_ids)
  end

  @doc """
  Gets a single part.

  Raises `Ecto.NoResultsError` if the Part does not exist.

  ## Examples

      iex> get_part!(123)
      %Part{}

      iex> get_part!(456)
      ** (Ecto.NoResultsError)

  """
  def get_part!(id) do
    Part
    |> Repo.get!(id)
    |> Repo.preload([:category, :manufacturer, :products])
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
    |> Repo.insert()
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

    part
    |> Part.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:products, products)
  end
end
