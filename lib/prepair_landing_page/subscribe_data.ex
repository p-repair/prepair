defmodule PrepairLandingPage.SubscribeData do
  use Ecto.Schema
  alias PrepairLandingPage.SubscribeData
  import Ecto.Changeset

  schema "subscribe_data" do
    field(:email)
  end

  def changeset(%SubscribeData{} = subscribe_data, params \\ %{}) do
    subscribe_data
    |> cast(params, [:email])
    |> validate_required([:email])
    |> validate_format(:email, ~r/@/)
  end
end
