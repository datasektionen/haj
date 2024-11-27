defmodule HajWeb.PollLiveTest do
  use HajWeb.ConnCase

  import Phoenix.LiveViewTest
  import Haj.PollsFixtures

  @create_attrs %{
    description: "some description",
    title: "some title",
    display_votes: true,
    allow_user_options: true
  }
  @update_attrs %{
    description: "some updated description",
    title: "some updated title",
    display_votes: false,
    allow_user_options: false
  }
  @invalid_attrs %{description: nil, title: nil, display_votes: false, allow_user_options: false}

  defp create_poll(_) do
    poll = poll_fixture()
    %{poll: poll}
  end

  describe "Index" do
    setup [:create_poll]

    test "lists all poll", %{conn: conn, poll: poll} do
      {:ok, _index_live, html} = live(conn, ~p"/settings/polls")

      assert html =~ "Listing Poll"
      assert html =~ poll.description
    end

    test "saves new poll", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/settings/polls")

      assert index_live |> element("a", "New Poll") |> render_click() =~
               "New Poll"

      assert_patch(index_live, ~p"/settings/polls/new")

      assert index_live
             |> form("#poll-form", poll: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#poll-form", poll: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/settings/polls")

      html = render(index_live)
      assert html =~ "Poll created successfully"
      assert html =~ "some description"
    end

    test "updates poll in listing", %{conn: conn, poll: poll} do
      {:ok, index_live, _html} = live(conn, ~p"/settings/polls")

      assert index_live |> element("#poll-#{poll.id} a", "Edit") |> render_click() =~
               "Edit Poll"

      assert_patch(index_live, ~p"/settings/polls/#{poll}/edit")

      assert index_live
             |> form("#poll-form", poll: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#poll-form", poll: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/settings/polls")

      html = render(index_live)
      assert html =~ "Poll updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes poll in listing", %{conn: conn, poll: poll} do
      {:ok, index_live, _html} = live(conn, ~p"/settings/polls")

      assert index_live |> element("#poll-#{poll.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#poll-#{poll.id}")
    end
  end

  describe "Show" do
    setup [:create_poll]

    test "displays poll", %{conn: conn, poll: poll} do
      {:ok, _show_live, html} = live(conn, ~p"/settings/polls/#{poll}")

      assert html =~ "Show Poll"
      assert html =~ poll.description
    end

    test "updates poll within modal", %{conn: conn, poll: poll} do
      {:ok, show_live, _html} = live(conn, ~p"/settings/polls/#{poll}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Poll"

      assert_patch(show_live, ~p"/settings/polls/#{poll}/show/edit")

      assert show_live
             |> form("#poll-form", poll: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#poll-form", poll: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/settings/polls/#{poll}")

      html = render(show_live)
      assert html =~ "Poll updated successfully"
      assert html =~ "some updated description"
    end
  end
end
