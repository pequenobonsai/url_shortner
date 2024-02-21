defmodule UrlShortnerWeb.StatsController do
  use UrlShortnerWeb, :controller

  def index(conn, _params) do
    urls = UrlShortner.urls_with_visit()
    render(conn, :index, urls: urls)
  end
end
