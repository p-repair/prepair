defmodule PrepairWeb.Api.Profiles.ProfileJSON do
  alias Prepair.Profiles.Profile
  alias Prepair.Repo

  @doc """
  Renders a list of profiles.
  """
  def index(%{profiles: profiles}) do
    %{data: for(profile <- profiles, do: data(profile))}
  end

  @doc """
  Renders a single profile.
  """
  def show(%{profile: profile}) do
    %{data: data(profile)}
  end

  def data(%Profile{} = profile) do
    profile = Repo.preload(profile, [:user])

    %{
      id: profile.id,
      username: profile.username,
      user_email: profile.user.email,
      user_role: profile.user.role,
      newsletter: profile.newsletter,
      created_at: profile.inserted_at
    }
  end
end
