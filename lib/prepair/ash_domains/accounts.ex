defmodule Prepair.AshDomains.Accounts do
  use Ash.Domain

  resources do
    resource Prepair.AshDomains.Accounts.User
    resource Prepair.AshDomains.Accounts.UserToken
  end
end
