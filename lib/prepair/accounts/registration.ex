defmodule Prepair.Accounts.Registration do
  use Ecto.Schema

  alias Prepair.Accounts.User
  alias Prepair.Profiles.Profile
  alias Prepair.Repo

  import Ecto.Changeset
  import PrepairWeb.Gettext
  import Ecto.Query

  @required_fields [
    :username,
    :email,
    :password,
    :password_confirmation,
    :people_in_household,
    :newsletter
  ]

  embedded_schema do
    field :username, :string
    field :email, :string
    field :password, :string
    field :password_confirmation, :string
    field :people_in_household, :integer
    field :newsletter, :boolean
  end

  def changeset(struct, params, _opts \\ []) do
    struct
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> unsafe_validate_unique(:username, Repo, query: from(u in Profile))
    |> validate_email()
    |> validate_password()
    |> validate_confirmation(:password, message: gettext("does not match"))
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/,
      message: dgettext("errors", "must have the @ sign and no spaces")
    )
    |> validate_length(:email, max: 160)
    |> unsafe_validate_unique(:email, Repo, query: from(u in User))
  end

  defp validate_password(changeset) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 8, max: 256)
    |> validate_format(:password, ~r/[a-z]/,
      message: "at least one lower case character"
    )
    |> validate_format(:password, ~r/[A-Z]/,
      message: "at least one upper case character"
    )
    |> validate_format(:password, ~r/[!?@#$%^&*_0-9]/,
      message: "at least one digit or punctuation character"
    )
  end
end
