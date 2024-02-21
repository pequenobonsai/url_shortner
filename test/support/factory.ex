defmodule UrlShortner.Factory do
  use ExMachina.Ecto, repo: UrlShortner.Repo

  def url_factory do
    url = Faker.Internet.url()
    original = UrlShortner.Url.Original.from_url(url)

    %UrlShortner.Url{
      original_raw: url,
      original: original,
      short: Faker.Internet.slug()
    }
  end

  def url_visit_factory do
    %UrlShortner.UrlVisit{
      url: build(:url),
      info: %{}
    }
  end
end
