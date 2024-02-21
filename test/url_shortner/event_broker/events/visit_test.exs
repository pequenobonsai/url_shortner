defmodule UrlShortner.EventBroker.Events.VisitTest do
  use UrlShortner.DataCase, async: true

  alias UrlShortner.EventBroker.Events.Visit
  alias UrlShortner.UrlVisit

  test "saves url visit for url" do
    url = %{id: url_id} = insert(:url)

    assert :ok = Visit.handle(%Visit{url: url, idempotency_key: Faker.UUID.v4()})
    assert [%UrlVisit{url_id: ^url_id}] = Repo.all(UrlVisit)
  end
end
