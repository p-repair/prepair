defmodule PrepairWeb.Api.Profiles.OwnershipJSON do
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

  defp data(%Ownership{} = ownership) do
    ownership = Repo.preload(ownership, [:profile, :product])

    %{
      id: ownership.id,
      profile_id: ownership.profile.id,
      profile_username: ownership.profile.username,
      product_id: ownership.product.id,
      product_name: ownership.product.name,
      product_reference: ownership.product.reference,
      price_of_purchase: ownership.price_of_purchase,
      date_of_purchase: ownership.date_of_purchase,
      warranty_duration_m: ownership.warranty_duration_m
    }
  end
end
