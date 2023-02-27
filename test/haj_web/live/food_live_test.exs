defmodule HajWeb.SettingsLive.FoodTest do
  use HajWeb.ConnCase

  import Phoenix.LiveViewTest
  import Haj.FoodsFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp create_food(_) do
    food = food_fixture()
    %{food: food}
  end

  describe "Index" do
    setup [:create_food]

    test "lists all foods", %{conn: conn, food: food} do
      {:ok, _index_live, html} = live(conn, ~p"/live/settings/foods")

      assert html =~ "Listing Foods"
      assert html =~ food.name
    end

    test "saves new food", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/live/settings/foods")

      assert index_live |> element("a", "New Food") |> render_click() =~
               "New Food"

      assert_patch(index_live, ~p"/live/settings/foods/new")

      assert index_live
             |> form("#food-form", food: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#food-form", food: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/live/settings/foods")

      html = render(index_live)
      assert html =~ "Food created successfully"
      assert html =~ "some name"
    end

    test "updates food in listing", %{conn: conn, food: food} do
      {:ok, index_live, _html} = live(conn, ~p"/live/settings/foods")

      assert index_live |> element("#foods-#{food.id} a", "Edit") |> render_click() =~
               "Edit Food"

      assert_patch(index_live, ~p"/live/settings/foods/#{food}/edit")

      assert index_live
             |> form("#food-form", food: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#food-form", food: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/live/settings/foods")

      html = render(index_live)
      assert html =~ "Food updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes food in listing", %{conn: conn, food: food} do
      {:ok, index_live, _html} = live(conn, ~p"/live/settings/foods")

      assert index_live |> element("#foods-#{food.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#foods-#{food.id}")
    end
  end

  describe "Show" do
    setup [:create_food]

    test "displays food", %{conn: conn, food: food} do
      {:ok, _show_live, html} = live(conn, ~p"/live/settings/foods/#{food}")

      assert html =~ "Show Food"
      assert html =~ food.name
    end

    test "updates food within modal", %{conn: conn, food: food} do
      {:ok, show_live, _html} = live(conn, ~p"/live/settings/foods/#{food}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Food"

      assert_patch(show_live, ~p"/live/settings/foods/#{food}/show/edit")

      assert show_live
             |> form("#food-form", food: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#food-form", food: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/live/settings/foods/#{food}")

      html = render(show_live)
      assert html =~ "Food updated successfully"
      assert html =~ "some updated name"
    end
  end
end
