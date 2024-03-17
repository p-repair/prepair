defmodule Prepair.Profiles do
  @moduledoc """
  The Profiles context.
  """

  import Ecto.Query, warn: false
  alias Prepair.Repo

  alias Prepair.Profiles.{Profile, Ownership}

  @doc """
  Returns the list of profiles.

  ## Examples

      iex> list_profiles()
      [%Profile{}, ...]

  """
  def list_profiles do
    Repo.all(Profile)
  end

  @doc """
  Gets a single profile.

  Raises `Ecto.NoResultsError` if the Profile does not exist.

  ## Examples

      iex> get_profile!(123)
      %Profile{}

      iex> get_profile!(456)
      ** (Ecto.NoResultsError)

  """
  def get_profile!(id), do: Repo.get!(Profile, id)

  @doc """
  Creates a profile.

  ## Examples

      iex> create_profile(id, %{field: value})
      {:ok, %Profile{}}

      iex> create_profile(id, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_profile(id, attrs \\ %{}) do
    %Profile{id: id}
    |> Profile.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a profile.

  ## Examples

      iex> update_profile(profile, %{field: new_value})
      {:ok, %Profile{}}

      iex> update_profile(profile, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_profile(%Profile{} = profile, attrs) do
    profile
    |> Profile.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking profile changes.

  ## Examples

      iex> change_profile(profile)
      %Ecto.Changeset{data: %Profile{}}

  """
  def change_profile(%Profile{} = profile, attrs \\ %{}) do
    Profile.changeset(profile, attrs)
  end

  @doc """
  Returns the list of all ownerships (public + private).

  ## Examples

      iex> list_ownerships()
      [%Ownership{public: false, …}, %Ownership{public: true, …} ...]

  """
  def list_ownerships do
    Repo.all(Ownership)
  end

  @doc """
  Returns the list of ownerships for a given profile / user id.

  ## Options:

  * `:public` - If set to `true`, returns only public ownerships linked to the
    profile. Otherwise, returns all ownerships.

  ## Examples

      iex> list_ownerships_by_profile(1)
      [%Ownership{public: false, …}, %Ownership{public: true…}, ...]

      iex> list_ownerships_by_profile(1, public: true)
      [%Ownership{public: true, …}, ...]

  """
  def list_ownerships_by_profile(profile_id, opts \\ []) do
    filters =
      [profile_id: profile_id] ++
        if opts[:include_private] == true, do: [], else: [public: true]

    query =
      from o in Ownership,
        where: ^filters,
        select: o

    Repo.all(query)
  end

  @doc """
  Returns the list of ownerships for a given product id.

  ## Options:

  * `:public` - If set to `true`, returns only public ownerships linked to the
    product. Otherwise, returns all ownerships.

  ## Examples

      iex> list_ownerships_by_product(1)
      [%Ownership{public: false, …}, %Ownership{public: true, …}, ...]

      iex> list_ownerships_by_product(1, public: true)
      [%Ownership{public: true, …}, ...]

  """
  def list_ownerships_by_product(product_id, opts \\ []) do
    filters =
      [product_id: product_id] ++
        if opts[:include_private] == true, do: [], else: [public: true]

    query =
      from o in Ownership,
        where: ^filters,
        select: o

    Repo.all(query)
  end

  @doc """
  Returns the ownership count for the given product id.

  ## Examples

      iex> count_ownerships_by_product(123)
      2

  """
  def count_ownerships_by_product(product_id) do
    query =
      from o in Ownership,
        where: o.product_id == ^product_id,
        select: count()

    Repo.all(query)
    |> Enum.fetch!(0)
  end

  @doc """
  Gets a single ownership.

  Raises `Ecto.NoResultsError` if the Ownership does not exist.

  ## Examples

      iex> get_ownership!(123)
      %Ownership{}

      iex> get_ownership!(456)
      ** (Ecto.NoResultsError)

  """
  def get_ownership!(id), do: Repo.get!(Ownership, id)

  @doc """
  Creates an ownership.

  ## Examples

      iex> create_ownership(%{field: value})
      {:ok, %Ownership{}}

      iex> create_ownership(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_ownership(profile_id, attrs \\ %{}) do
    %Ownership{profile_id: profile_id}
    |> Ownership.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an ownership.

  ## Examples

      iex> update_ownership(ownership, %{field: new_value})
      {:ok, %Ownership{}}

      iex> update_ownership(ownership, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def update_ownership(%Ownership{} = ownership, attrs) do
    ownership
    |> Ownership.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an ownership.

  ## Examples

      iex> delete_ownership(ownership)
      {:ok, %Ownership{}}

      iex> delete_ownership(ownership)
      {:error, %Ecto.Changeset{}}

  """
  def delete_ownership(%Ownership{} = ownership) do
    Repo.delete(ownership)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking ownership changes.

  ## Examples

      iex> change_ownership(ownership)
      %Ecto.Changeset{data: %Ownership{}}

  """
  def change_ownership(%Ownership{} = ownership, attrs \\ %{}) do
    Ownership.changeset(ownership, attrs)
  end
end
