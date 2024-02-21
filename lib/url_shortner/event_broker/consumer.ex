defmodule UrlShortner.EventBroker.Consumer do
  @moduledoc """
  Right now it starts an genserver in the application supervision tree
  which listens for messages through distributed PubSub that comes with
  phoenix but could be anything else like kafka, rabbitmq, etc.
  """

  use GenServer, restart: :permanent

  @topic Application.compile_env!(:url_shortner, :event_broker_topic)

  def start_link(default) when is_list(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  @impl GenServer
  def init(state) do
    Phoenix.PubSub.subscribe(UrlShortner.PubSub, @topic)
    {:ok, state}
  end

  @impl GenServer

  def handle_info({:event, event = %event_module{}}, state) do
    event_module.handle(event)
    {:noreply, state}
  end
end
