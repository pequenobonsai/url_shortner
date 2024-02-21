defmodule UrlShortnerWeb.StatsControllerTest do
  use UrlShortnerWeb.ConnCase, async: true

  test "index show stats for url visits", %{conn: conn} do
    url = insert(:url)
    url2 = insert(:url)
    url3 = insert(:url)

    insert_list(3, :url_visit, url: url)
    insert_list(10, :url_visit, url: url2)
    insert_list(5, :url_visit, url: url3)

    conn = get(conn, ~p"/stats")

    assert html = html_response(conn, 200)

    heads = html |> Floki.find("table tr th") |> Enum.map(&Floki.text/1)

    assert [
             [
               {"ID", url2.id},
               {"Short", url(conn, ~p"/#{url2.short}")},
               {"Destination URL", url2.original_raw},
               {"Visits", "10"}
             ],
             [
               {"ID", url3.id},
               {"Short", url(conn, ~p"/#{url3.short}")},
               {"Destination URL", url3.original_raw},
               {"Visits", "5"}
             ],
             [
               {"ID", url.id},
               {"Short", url(conn, ~p"/#{url.short}")},
               {"Destination URL", url.original_raw},
               {"Visits", "3"}
             ]
           ] ==
             html
             |> Floki.find("table tr td")
             |> Enum.map(&(&1 |> Floki.text() |> String.trim()))
             # Every 4 because we have four columns on the table, to match heads
             |> Enum.chunk_every(4)
             |> Enum.map(&Enum.zip(heads, &1))
  end
end
