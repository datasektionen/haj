defmodule HajWeb.ResponsibilityLiveTest do
  use HajWeb.ConnCase

  import Phoenix.LiveViewTest
  import Haj.ResponsibilitiesFixtures

  @create_attrs %{description: "some description", name: "some name"}
  @update_attrs %{description: "some updated description", name: "some updated name"}
  @invalid_attrs %{description: nil, name: nil}

  defp create_responsibility(_) do
    responsibility = responsibility_fixture()
    %{responsibility: responsibility}
  end

  describe "Index" do
    setup [:create_responsibility]

    test "lists all responsibilities", %{conn: conn, responsibility: responsibility} do
      {:ok, _index_live, html} = live(conn, ~p"/responsibilities")

      assert html =~ "Listing Responsibilities"
      assert html =~ responsibility.description
    end

    test "saves new responsibility", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/responsibilities")

      assert index_live |> element("a", "New Responsibility") |> render_click() =~
               "New Responsibility"

      assert_patch(index_live, ~p"/responsibilities/new")

      assert index_live
             |> form("#responsibility-form", responsibility: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#responsibility-form", responsibility: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/responsibilities")

      assert html =~ "Responsibility created successfully"
      assert html =~ "some description"
    end

    test "updates responsibility in listing", %{conn: conn, responsibility: responsibility} do
      {:ok, index_live, _html} = live(conn, ~p"/responsibilities")

      assert index_live |> element("#responsibilities-#{responsibility.id} a", "Edit") |> render_click() =~
               "Edit Responsibility"

      assert_patch(index_live, ~p"/responsibilities/#{responsibility}/edit")

      assert index_live
             |> form("#responsibility-form", responsibility: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#responsibility-form", responsibility: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/responsibilities")

      assert html =~ "Responsibility updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes responsibility in listing", %{conn: conn, responsibility: responsibility} do
      {:ok, index_live, _html} = live(conn, ~p"/responsibilities")

      assert index_live |> element("#responsibilities-#{responsibility.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#responsibility-#{responsibility.id}")
    end
  end

  describe "Show" do
    setup [:create_responsibility]

    test "displays responsibility", %{conn: conn, responsibility: responsibility} do
      {:ok, _show_live, html} = live(conn, ~p"/responsibilities/#{responsibility}")

      assert html =~ "Show Responsibility"
      assert html =~ responsibility.description
    end

    test "updates responsibility within modal", %{conn: conn, responsibility: responsibility} do
      {:ok, show_live, _html} = live(conn, ~p"/responsibilities/#{responsibility}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Responsibility"

      assert_patch(show_live, ~p"/responsibilities/#{responsibility}/show/edit")

      assert show_live
             |> form("#responsibility-form", responsibility: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#responsibility-form", responsibility: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/responsibilities/#{responsibility}")

      assert html =~ "Responsibility updated successfully"
      assert html =~ "some updated description"
    end
  end
end
