defmodule Haj.S3 do
  def s3_url(path) do
    {:ok, url} =
      ExAws.Config.new(:s3, region: "eu-north-1")
      |> ExAws.S3.presigned_url(:get, "metaspexet-haj", path, virtual_host: true)

    url
  end

  def base_url() do
    {:ok, url} =
      ExAws.Config.new(:s3, region: "eu-north-1")
      |> ExAws.S3.presigned_url(:get, "metaspexet-haj", "test", virtual_host: true)

    url |> String.split("test") |> List.first()
  end
end
