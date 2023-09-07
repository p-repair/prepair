defmodule PrepairWeb.PartLiveTest do
  use PrepairWeb.ConnCase

  import Phoenix.LiveViewTest
  import Prepair.ProductsFixtures

  @update_attrs %{
    average_lifetime_m: 43,
    country_of_origin: "some updated country_of_origin",
    description: "some updated description",
    end_of_production: "2023-07-12",
    image: "some updated image",
    main_material: "some updated main_material",
    name: "some updated name",
    reference: "some updated reference",
    start_of_production: "2023-07-12"
  }
  @invalid_attrs %{
    average_lifetime_m: nil,
    country_of_origin: nil,
    description: nil,
    end_of_production: nil,
    image: nil,
    main_material: nil,
    name: nil,
    reference: nil,
    start_of_production: nil
  }

  defp create_part(_) do
    part = part_fixture()
    %{part: part}
  end

  describe "Index" do
    setup [:create_part, :register_and_log_in_user]

    test "lists all parts", %{conn: conn, part: part} do
      {:ok, _index_live, html} = live(conn, ~p"/parts")

      assert html =~ "Listing Parts"
      assert html =~ part.country_of_origin
    end

    test "saves new part", %{conn: conn} do
      valid_attrs = part_valid_attrs()

      {:ok, index_live, _html} = live(conn, ~p"/parts")

      assert index_live |> element("a", "New Part") |> render_click() =~
               "New Part"

      assert_patch(index_live, ~p"/parts/new")

      assert index_live
             |> form("#part-form", part: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#part-form", part: valid_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/parts")

      html = render(index_live)
      assert html =~ "Part created successfully"
      assert html =~ "some country_of_origin"
    end

    test "updates part in listing", %{conn: conn, part: part} do
      {:ok, index_live, _html} = live(conn, ~p"/parts")

      assert index_live
             |> element("#parts-#{part.id} a", "Edit")
             |> render_click() =~
               "Edit Part"

      assert_patch(index_live, ~p"/parts/#{part}/edit")

      assert index_live
             |> form("#part-form", part: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#part-form", part: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/parts")

      html = render(index_live)
      assert html =~ "Part updated successfully"
      assert html =~ "some updated country_of_origin"
    end

    test "deletes part in listing", %{conn: conn, part: part} do
      {:ok, index_live, _html} = live(conn, ~p"/parts")

      assert index_live
             |> element("#parts-#{part.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#parts-#{part.id}")
    end
  end

  describe "Show" do
    setup [:create_part, :register_and_log_in_user]

    test "displays part", %{conn: conn, part: part} do
      {:ok, _show_live, html} = live(conn, ~p"/parts/#{part}")

      assert html =~ "Show Part"
      assert html =~ part.country_of_origin
    end

    test "updates part within modal", %{conn: conn, part: part} do
      {:ok, show_live, _html} = live(conn, ~p"/parts/#{part}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Part"

      assert_patch(show_live, ~p"/parts/#{part}/show/edit")

      assert show_live
             |> form("#part-form", part: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#part-form", part: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/parts/#{part}")

      html = render(show_live)
      assert html =~ "Part updated successfully"
      assert html =~ "some updated country_of_origin"
    end
  end
end
