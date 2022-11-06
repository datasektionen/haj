defmodule Haj.Image do
  @moduledoc """
  Module for interacting with images
  """

  def new(path) do
    Imgproxy.new("s3://metaspexet-haj#{path}") |> Imgproxy.set_extension("webp")
  end
end
