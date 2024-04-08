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
      uuid: user.uuid,
      email: user.email
    }
  end
end
