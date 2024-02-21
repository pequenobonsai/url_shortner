defmodule UrlShortnerWeb.PageControllerTest do
  use UrlShortnerWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    html = conn |> html_response(200) |> Floki.text()

    assert html =~ "Shorten new url"
    assert html =~ "Stats"
  end
end
