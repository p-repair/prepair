defmodule PrepairWeb.ProductLive.Index do
  use PrepairWeb, :live_view

  alias Prepair.Products
  alias Prepair.Products.Product

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> stream_configure(:products,
        dom_id: &"products-#{&1.uuid}"
      )
      |> stream(:products, Products.list_products())

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"uuid" => uuid}) do
    socket
    |> assign(:page_title, "Edit Product")
    |> assign(:product, Products.get_product!(uuid))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Product")
    |> assign(:product, %Product{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Products")
    |> assign(:product, nil)
  end

  @impl true
  def handle_info(
        {PrepairWeb.ProductLive.FormComponent, {:saved, product}},
        socket
      ) do
    {:noreply, stream_insert(socket, :products, product)}
  end

  @impl true
  def handle_event("delete", %{"uuid" => uuid}, socket) do
    product = Products.get_product!(uuid)
    {:ok, _} = Products.delete_product(product)

    {:noreply, stream_delete(socket, :products, product)}
  end
end
