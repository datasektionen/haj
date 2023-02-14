defmodule Haj.Presence do
  use Phoenix.Presence, otp_app: :event_page_otpapp, pubsub_server: Haj.PubSub
end
