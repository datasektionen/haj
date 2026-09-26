defmodule ProfilePictureService do
  @moduledoc """
  Behaviour for profile picture services.

  This behaviour defines the contract for services that manage user profile pictures.
  Implementations can be external APIs (like rfinger) or test mocks.
  """

  alias Haj.Accounts.User

  @doc """
  Starts the permission service GenServer.

  This is called when the service is added to the supervision tree.
  """
  @callback start_link(keyword()) :: GenServer.on_start()

  @doc """
  Gets a profile picture url for a single user

  Returns an url to the profile picture
  """
  @callback get_picture(User.t()) :: String.t()

  @doc """
  Clears the link cache.

  This is useful for invalidating cached links when they change.
  """
  @callback clear() :: :ok
end
