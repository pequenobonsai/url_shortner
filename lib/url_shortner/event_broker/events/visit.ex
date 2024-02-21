defmodule UrlShortner.EventBroker.Events.Visit do
  defstruct [:url, :idempotency_key]

  alias UrlShortner.EventBroker.Event
  alias UrlShortner.Url

  @behaviour Event

  @type t :: %{
          url: Url.t(),
          idempotency_key: String.t()
        }

  @impl Event
  def handle(%__MODULE__{url: url, idempotency_key: idempotency_key}) do
    UrlShortner.create_url_visit_for(url, idempotency_key)
    :ok
  end
end
