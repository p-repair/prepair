defmodule PrepairWeb.Api.Profiles.ProfileJSON do
  alias Prepair.LegacyContexts.Profiles.Profile
  alias Prepair.AshDomains.Profiles.Profile, as: AshProfile
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
      people_in_household: profile.people_in_household,
      user_email: profile.user.email,
      user_role: profile.user.role,
      newsletter: profile.newsletter,
      created_at: profile.inserted_at
    }
  end

  def data(%AshProfile{} = profile) do
    profile = Ash.load!(profile, [:user])

    %{
      id: profile.id,
      username: profile.username,
      people_in_household: profile.people_in_household,
      user_email: profile.user.email,
      user_role: profile.user.role,
      newsletter: profile.newsletter,
      created_at: profile.inserted_at
    }
  end
end
