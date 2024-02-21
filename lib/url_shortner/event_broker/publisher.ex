defmodule UrlShortner.EventBroker.Publisher do
  @moduledoc """
  Behaviour and reference implementation for a publisher.
  Right now uses distrubuted PubSub that comes with phoenix
  but could be any other external system like kafka, rabbitmq, etc.
  """
  alias UrlShortner.EventBroker.Event

  @doc "Should not be used directly, go through `UrlShortner.EventBroker.publish/1`"
  @callback publish(Event.kind()) :: :ok

  @behaviour __MODULE__

  @topic Application.compile_env!(:url_shortner, :event_broker_topic)

  @impl __MODULE__
  def publish(event) do
    Phoenix.PubSub.broadcast(UrlShortner.PubSub, @topic, {:event, event})
  end
end
