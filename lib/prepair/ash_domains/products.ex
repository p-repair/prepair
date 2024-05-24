defmodule Prepair.AshDomains.Products do
  # TODO: Moduledoc.
  use Ash.Domain

  resources do
    resource Prepair.AshDomains.Products.Category
    resource Prepair.AshDomains.Products.Manufacturer
    resource Prepair.AshDomains.Products.Product
    resource Prepair.AshDomains.Products.Part
    resource Prepair.AshDomains.Products.ProductParts
  end
end
