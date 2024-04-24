defmodule PrepairWeb.Api.Accounts.UserJSON do
  alias Prepair.Accounts.User

  @doc """
  Renders a single user.
  """

  def show(%{user: user}) do
    %{data: data(user)}
  end

  def data(%User{} = user) do
    %{
      id: user.id,
      email: user.email
    }
  end
end
