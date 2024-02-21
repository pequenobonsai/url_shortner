defmodule UrlShortner.EventBroker do
  @moduledoc """
  Main API for publishing an event.
  """

  alias UrlShortner.EventBroker.Event

  @spec publish(Event.kind()) :: :ok
  def publish(event) do
    publisher = Application.get_env(:url_shortner, :event_broker_publisher)
    publisher.publish(event)
  end
end
