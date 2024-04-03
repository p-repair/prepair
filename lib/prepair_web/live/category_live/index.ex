defmodule PrepairWeb.CategoryLive.Index do
  use PrepairWeb, :live_view

  alias Prepair.Products
  alias Prepair.Products.Category

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> stream_configure(:categories,
        dom_id: &"categories-#{&1.uuid}"
      )
      |> stream(:categories, Products.list_categories())

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"uuid" => uuid}) do
    page_title = gettext("Edit Category")

    socket
    |> assign(:page_title, page_title)
    |> assign(:category, Products.get_category!(uuid))
  end

  defp apply_action(socket, :new, _params) do
    page_title = gettext("New Category")

    socket
    |> assign(:page_title, page_title)
    |> assign(:category, %Category{})
  end

  defp apply_action(socket, :index, _params) do
    page_title = gettext("Listing Categories")

    socket
    |> assign(:page_title, page_title)
    |> assign(:category, nil)
  end

  @impl true
  def handle_info(
        {PrepairWeb.CategoryLive.FormComponent, {:saved, category}},
        socket
      ) do
    {:noreply, stream_insert(socket, :categories, category)}
  end

  @impl true
  def handle_event("delete", %{"uuid" => uuid}, socket) do
    category = Products.get_category!(uuid)
    {:ok, _} = Products.delete_category(category)

    {:noreply, stream_delete(socket, :categories, category)}
  end
end
