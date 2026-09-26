defmodule Haj.Rfinger do
  @moduledoc """
  Implementation of ProfilePictureService that fetches picture links from the rfinger API.

  Rfinger is an external service that manages users profile pictures. This module caches
  links in ETS for 24 hours to reduce API calls.
  """

  use GenServer
  @behaviour ProfilePictureService

  alias Haj.Accounts.User

  # 24 timmar
  @ttl 1000 * 60 * 60 * 24

  @impl ProfilePictureService
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl ProfilePictureService
  def get_picture(user) do
    GenServer.call(__MODULE__, {:get_picture, user}, 10_000)
  end

  @impl ProfilePictureService
  def clear() do
    GenServer.cast(__MODULE__, :clear)
    :ok
  end

  @impl GenServer
  def init(_) do
    :ets.new(:haj_rfinger, [:named_table, :set, :protected])
    {:ok, %{timers: %{}}}
  end

  @impl GenServer
  def handle_call({:get_picture, user}, _from, state) do
    username = user.username

    case :ets.lookup(:haj_rfinger, username) do
      [{^username, link}] ->
        {:reply, link, state}

      [] ->
        link = fetch_link(user)

        :ets.insert(:haj_rfinger, {username, link})
        timer = Process.send_after(self(), {:invalidate, username}, @ttl)

        {:reply, link, %{state | timers: Map.put(state.timers, username, timer)}}
    end
  end

  @impl GenServer
  def handle_cast(:clear, %{timers: timers}) do
    for {_, timer} <- timers do
      Process.cancel_timer(timer)
    end

    :ets.delete(:haj_rfinger)
    :ets.new(:haj_rfinger, [:named_table, :set, :protected])
    {:noreply, %{timers: %{}}}
  end

  @impl GenServer
  def handle_info({:invalidate, username}, state) do
    :ets.delete(:haj_rfinger, username)
    {:noreply, state}
  end

  defp fetch_link(%User{username: username}) do
    resp =
      Req.get(rfinger_url() <> "/#{username}",
        headers: [
          {"Accept", "application/json"},
          {"Authorization", "Bearer #{rfinger_api_token()}"}
        ]
      )

    case resp do
      {:ok, %{status: 200, body: body}} -> body
      _ -> "unknown"
    end
  end

  defp rfinger_url do
    Application.get_env(:haj, :rfinger_url)
  end

  defp rfinger_api_token do
    Application.get_env(:haj, :rfinger_api_token)
  end
end
