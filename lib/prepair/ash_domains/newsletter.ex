defmodule Prepair.AshDomains.Newsletter do
  use Ash.Domain

  resources do
    resource Prepair.AshDomains.Newsletter.Contact
  end
end
