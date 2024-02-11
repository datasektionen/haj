defmodule HajWeb.FormLiveTest do
  use HajWeb.ConnCase

  import Phoenix.LiveViewTest
  import Haj.FormsFixtures

  @create_attrs %{description: "some description", name: "some name"}
  @update_attrs %{description: "some updated description", name: "some updated name"}
  @invalid_attrs %{description: nil, name: nil}

  defp create_form(_) do
    form = form_fixture()
    %{form: form}
  end

  describe "Index" do
    setup [:create_form]

    test "lists all forms", %{conn: conn, form: form} do
      {:ok, _index_live, html} = live(conn, ~p"/settings/forms")

      assert html =~ "Listing Forms"
      assert html =~ form.description
    end

    test "saves new form", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/settings/forms")

      assert index_live |> element("a", "New Form") |> render_click() =~
               "New Form"

      assert_patch(index_live, ~p"/settings/forms/new")

      assert index_live
             |> form("#form-form", form: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#form-form", form: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/settings/forms")

      html = render(index_live)
      assert html =~ "Form created successfully"
      assert html =~ "some description"
    end

    test "updates form in listing", %{conn: conn, form: form} do
      {:ok, index_live, _html} = live(conn, ~p"/settings/forms")

      assert index_live |> element("#forms-#{form.id} a", "Edit") |> render_click() =~
               "Edit Form"

      assert_patch(index_live, ~p"/settings/forms/#{form}/edit")

      assert index_live
             |> form("#form-form", form: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#form-form", form: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/settings/forms")

      html = render(index_live)
      assert html =~ "Form updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes form in listing", %{conn: conn, form: form} do
      {:ok, index_live, _html} = live(conn, ~p"/settings/forms")

      assert index_live |> element("#forms-#{form.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#forms-#{form.id}")
    end
  end

  describe "Show" do
    setup [:create_form]

    test "displays form", %{conn: conn, form: form} do
      {:ok, _show_live, html} = live(conn, ~p"/settings/forms/#{form}")

      assert html =~ "Show Form"
      assert html =~ form.description
    end

    test "updates form within modal", %{conn: conn, form: form} do
      {:ok, show_live, _html} = live(conn, ~p"/settings/forms/#{form}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Form"

      assert_patch(show_live, ~p"/settings/forms/#{form}/show/edit")

      assert show_live
             |> form("#form-form", form: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#form-form", form: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/settings/forms/#{form}")

      html = render(show_live)
      assert html =~ "Form updated successfully"
      assert html =~ "some updated description"
    end
  end
end
