defmodule PrepairWeb.Api.Profiles.OwnershipJSON do
  alias Prepair.Profiles.Ownership
  alias Prepair.Products
  alias Prepair.Repo

  @doc """
  Renders a list of ownerships.
  """
  def index(%{ownerships: ownerships}) do
    %{data: for(ownership <- ownerships, do: data(ownership))}
  end

  @doc """
  Renders a single ownership.
  """
  def show(%{ownership: ownership}) do
    %{data: data(ownership)}
  end

  def data(%Ownership{} = ownership) do
    ownership = Repo.preload(ownership, [:profile, :product])
    manufacturer = Products.get_manufacturer!(ownership.product.manufacturer_id)

    # Appeler la fonction ProductJSON.data pour récupérer tous les champs du product.
    # product: ProductJSON.data(ownership.product) -> fonction à déprivatiser

    %{
      id: ownership.id,
      profile_id: ownership.profile.id,
      profile_username: ownership.profile.username,
      product_id: ownership.product.id,
      product_manufacturer_name: manufacturer.name,
      product_manufacturer_id: manufacturer.id,
      product_name: ownership.product.name,
      product_reference: ownership.product.reference,
      price_of_purchase: ownership.price_of_purchase,
      date_of_purchase: ownership.date_of_purchase,
      warranty_duration_m: ownership.warranty_duration_m,
      public: ownership.public
    }
  end
end
