defmodule UrlShortner.EventBroker.Events.Visit do
  defstruct [:url]

  alias UrlShortner.EventBroker.Event
  alias UrlShortner.Url

  @behaviour Event

  @type t :: %{
          url: Url.t()
        }

  @impl Event
  def handle(%__MODULE__{url: url}) do
    UrlShortner.create_url_visit_for(url)
    :ok
  end
end
