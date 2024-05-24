defmodule Prepair.AshDomains.Profiles do
  use Ash.Domain

  resources do
    resource Prepair.AshDomains.Profiles.Ownership
    resource Prepair.AshDomains.Profiles.Profile
  end
end
