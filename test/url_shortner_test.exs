defmodule UrlShortnerTest do
  use UrlShortner.DataCase
  alias UrlShortner.Url

  test "get_url!/1 returns the url with given id" do
    url = insert(:url)
    assert UrlShortner.get_url!(url.id) == url
  end

  describe "create_url/1" do
    test "with valid data creates a url" do
      valid_attrs = %{original_raw: "https://example.org"}

      assert {:ok, %Url{} = url} = UrlShortner.create_url(valid_attrs)
      assert url.original_raw == "https://example.org"

      assert url.original == %Url.Original{
               fragment: nil,
               host: "example.org",
               path: nil,
               port: 443,
               query: nil,
               scheme: "https",
               userinfo: nil
             }

      refute url.short == ""
    end

    test "with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = UrlShortner.create_url(%{original_raw: nil})
    end
  end

  test "change_url/1 returns a url changeset" do
    url = insert(:url)
    assert %Ecto.Changeset{} = UrlShortner.change_url(url)
  end
end
