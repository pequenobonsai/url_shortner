defmodule UrlShortnerWeb.UrlControllerTest do
  use UrlShortnerWeb.ConnCase, async: true
  import Mox

  setup :verify_on_exit!

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

      html = conn |> html_response(200)

      assert html =~ "Oops, something went wrong! Please check the errors below."
      assert Floki.text(html) =~ "can't be blank"

      conn = post(conn, ~p"/urls", url: %{original_raw: "https://"})
      html = conn |> html_response(200)

      assert html =~ "Oops, something went wrong! Please check the errors below."
      assert Floki.text(html) =~ "Invalid URL"

      existing_url = insert(:url)
      expect(KeyGeneratorMock, :generate, fn -> existing_url.short end)

      conn = post(conn, ~p"/urls", url: %{original_raw: "https://example.org"})
      html = conn |> html_response(200)

      assert html =~ "Oops, something went wrong! Please check the errors below."
      assert Floki.text(html) =~ "had an error generating short url, try again"
    end
  end
end
