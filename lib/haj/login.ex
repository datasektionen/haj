defmodule Haj.Login do
  @moduledoc """
  Module for interacting with `login` system. It is undocumented but works in the following way
  """

  def authorize_url() do
    login_url = Application.get_env(:haj, :login_url)
    hostname = Application.get_env(:haj, :hostname)
    port = Application.get_env(:haj, :port)

    callback = URI.encode("#{hostname}:#{port}/login/callback/?token=")
    "#{login_url}/login?callback=#{callback}"
  end
end
