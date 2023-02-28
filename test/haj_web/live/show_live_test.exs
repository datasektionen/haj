defmodule HajWeb.SettingsLive.ShowTest do
  use HajWeb.ConnCase

  import Phoenix.LiveViewTest
  import Haj.SpexFixtures

  @create_attrs %{
    application_closes: "2023-02-21T08:29:00Z",
    application_opens: "2023-02-21T08:29:00Z",
    description: "some description",
    or_title: "some or_title",
    slack_webhook_url: "some slack_webhook_url",
    title: "some title",
    year: "2023-02-21"
  }
  @update_attrs %{
    application_closes: "2023-02-22T08:29:00Z",
    application_opens: "2023-02-22T08:29:00Z",
    description: "some updated description",
    or_title: "some updated or_title",
    slack_webhook_url: "some updated slack_webhook_url",
    title: "some updated title",
    year: "2023-02-22"
  }
  @invalid_attrs %{
    application_closes: nil,
    application_opens: nil,
    description: nil,
    or_title: nil,
    slack_webhook_url: nil,
    title: nil,
    year: nil
  }

  defp create_show(_) do
    show = show_fixture()
    %{show: show}
  end

  describe "Index" do
    setup [:create_show]

    test "lists all shows", %{conn: conn, show: show} do
      {:ok, _index_live, html} = live(conn, ~p"/live/settings/shows")

      assert html =~ "Listing Shows"
      assert html =~ show.description
    end

    test "saves new show", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/live/settings/shows")

      assert index_live |> element("a", "New Show") |> render_click() =~
               "New Show"

      assert_patch(index_live, ~p"/live/settings/shows/new")

      assert index_live
             |> form("#show-form", show: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#show-form", show: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/live/settings/shows")

      html = render(index_live)
      assert html =~ "Show created successfully"
      assert html =~ "some description"
    end

    test "updates show in listing", %{conn: conn, show: show} do
      {:ok, index_live, _html} = live(conn, ~p"/live/settings/shows")

      assert index_live |> element("#shows-#{show.id} a", "Edit") |> render_click() =~
               "Edit Show"

      assert_patch(index_live, ~p"/live/settings/shows/#{show}/edit")

      assert index_live
             |> form("#show-form", show: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#show-form", show: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/live/settings/shows")

      html = render(index_live)
      assert html =~ "Show updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes show in listing", %{conn: conn, show: show} do
      {:ok, index_live, _html} = live(conn, ~p"/live/settings/shows")

      assert index_live |> element("#shows-#{show.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#shows-#{show.id}")
    end
  end

  describe "Show" do
    setup [:create_show]

    test "displays show", %{conn: conn, show: show} do
      {:ok, _show_live, html} = live(conn, ~p"/live/settings/shows/#{show}")

      assert html =~ "Show Show"
      assert html =~ show.description
    end

    test "updates show within modal", %{conn: conn, show: show} do
      {:ok, show_live, _html} = live(conn, ~p"/live/settings/shows/#{show}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Show"

      assert_patch(show_live, ~p"/live/settings/shows/#{show}/show/edit")

      assert show_live
             |> form("#show-form", show: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#show-form", show: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/live/settings/shows/#{show}")

      html = render(show_live)
      assert html =~ "Show updated successfully"
      assert html =~ "some updated description"
    end
  end
end
