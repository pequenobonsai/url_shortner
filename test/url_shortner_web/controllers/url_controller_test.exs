defmodule UrlShortnerWeb.UrlControllerTest do
  use UrlShortnerWeb.ConnCase

  describe "new url" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/urls/new")
      assert html_response(conn, 200) =~ "Shorten an URL"
    end
  end

  describe "create url" do
    test "redirects to show when data is valid", %{conn: conn} do
      url = Faker.Internet.url()

      conn = post(conn, ~p"/urls", url: %{original_raw: url})

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/urls/#{id}"

      conn = get(conn, ~p"/urls/#{id}")
      assert html_response(conn, 200) =~ "URL <kbd>/"
      assert html_response(conn, 200) =~ url
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/urls", url: %{original_raw: nil})

      assert html_response(conn, 200) =~
               "Oops, something went wrong! Please check the errors below."
    end
  end
end
