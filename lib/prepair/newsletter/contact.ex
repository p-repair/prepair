defmodule Prepair.Newsletter.Contact do
  use TypedEctoSchema

  alias Prepair.Newsletter.Contact
  alias Ecto.Changeset

  import Ecto.Changeset

  typed_schema "contacts" do
    field :email, :string
    field :lang, :string
    field :mailerlite_id, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  @spec changeset(t(), map()) :: Changeset.t()
  def changeset(%Contact{} = contacts, params \\ %{}) do
    contacts
    |> cast(params, [:email, :lang, :mailerlite_id])
    |> validate_required([:email])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end
end
