defmodule PrepairWeb.Api.Profiles.OwnershipJSON do
  alias PrepairWeb.Api.Products.ProductJSON
  alias PrepairWeb.Api.Profiles.ProfileJSON
  alias Prepair.Profiles.Ownership
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

    %{
      id: ownership.id,
      profile: ProfileJSON.data(ownership.profile),
      product: ProductJSON.data(ownership.product),
      price_of_purchase: ownership.price_of_purchase,
      date_of_purchase: ownership.date_of_purchase,
      warranty_duration_m: ownership.warranty_duration_m,
      public: ownership.public
    }
  end
end
