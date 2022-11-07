defmodule Haj.Image do
  @moduledoc """
  Module for interacting with images
  """

  def new(path) do
    Imgproxy.new("#{path}") |> Imgproxy.set_extension("webp")
  end

  # generates a url for path
  def video_url(path) do
    prefix = Application.get_env(:imgproxy, :prefix)

    "#{prefix}/videos#{path}"
  end
end
