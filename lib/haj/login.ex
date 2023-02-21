defmodule Haj.Login do
  @moduledoc """
  Module for interacting with `login` system. It is undocumented but works in the following way
  """

  def authorize_url() do
    login_host = Application.get_env(:haj, :login_host)
    hostname = Application.get_env(:haj, :hostname)
    port = Application.get_env(:haj, :port)

    callback = URI.encode("https://#{hostname}:#{port}/login/callback/?token=")
    "https://#{login_host}/login?callback=#{callback}"
  end
end
