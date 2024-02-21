defmodule UrlShortnerTest do
  use UrlShortner.DataCase, async: true
  import Mox
  alias UrlShortner.Url
  alias UrlShortner.UrlVisit
  alias UrlShortner.Repo

  setup :verify_on_exit!

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
      assert {:error, %Ecto.Changeset{errors: errors}} =
               UrlShortner.create_url(%{original_raw: nil})

      assert [original_raw: {"can't be blank", _}] = errors
    end

    test "with an invalid URL it returns an error" do
      assert {:error, %Ecto.Changeset{errors: errors}} =
               UrlShortner.create_url(%{original_raw: ""})

      assert [original_raw: {"can't be blank", _}] = errors

      assert {:error, %Ecto.Changeset{errors: errors}} =
               UrlShortner.create_url(%{original_raw: "htt"})

      assert [original_raw: {"Invalid URL", _}] = errors

      assert {:error, %Ecto.Changeset{errors: errors}} =
               UrlShortner.create_url(%{original_raw: "https//"})

      assert [original_raw: {"Invalid URL", _}] = errors

      assert {:error, %Ecto.Changeset{errors: errors}} =
               UrlShortner.create_url(%{original_raw: "https://"})

      assert [original_raw: {"Invalid URL", _}] = errors

      assert {:error, %Ecto.Changeset{errors: errors}} =
               UrlShortner.create_url(%{original_raw: "https//domain"})

      assert [original_raw: {"Invalid URL", _}] = errors

      assert {:error, %Ecto.Changeset{errors: errors}} =
               UrlShortner.create_url(%{original_raw: "://domain"})

      assert [original_raw: {"Invalid URL", _}] = errors
    end

    test "when trying to use an existing short url it returns an error" do
      existing_url = insert(:url)
      valid_attrs = %{original_raw: "https://example.org"}

      expect(KeyGeneratorMock, :generate, fn -> existing_url.short end)

      assert {:error, %Ecto.Changeset{errors: errors}} =
               UrlShortner.create_url(valid_attrs)

      assert [original_raw: {"had an error generating short url, try again", _}] =
               errors
    end
  end

  test "change_url/1 returns a url changeset" do
    url = insert(:url)
    assert %Ecto.Changeset{} = UrlShortner.change_url(url)
  end

  describe "urls_with_visit/0" do
    test "returns urls with visit count from counting UrlVisits" do
      %{id: url_id} = url = insert(:url)
      %{id: url2_id} = url2 = insert(:url)

      insert_list(10, :url_visit, url: url)
      insert_list(5, :url_visit, url: url2)

      assert [%Url{id: ^url_id, visits: 10}, %Url{id: ^url2_id, visits: 5}] =
               UrlShortner.urls_with_visit()
    end

    test "returns 0 for urls with no visit count" do
      %{id: url_id} = url = insert(:url)
      %{id: url2_id} = url2 = insert(:url)
      %{id: url3_id} = insert(:url)

      insert_list(10, :url_visit, url: url)
      insert_list(5, :url_visit, url: url2)

      assert [
               %Url{id: ^url_id, visits: 10},
               %Url{id: ^url2_id, visits: 5},
               %Url{id: ^url3_id, visits: 0}
             ] = UrlShortner.urls_with_visit()
    end
  end

  describe "create_url_visit_for/2" do
    test "does not create a new url visit for the same idempotency key" do
      url_visit = insert(:url_visit)
      UrlShortner.create_url_visit_for(url_visit.url, url_visit.idempotency_key)
      assert 1 == Repo.all(UrlVisit) |> Enum.count()
    end

    test "creates a new one if with same idempotency key does not exist for url" do
      url = insert(:url)
      UrlShortner.create_url_visit_for(url, Faker.UUID.v4())
      assert 1 == Repo.all(UrlVisit) |> Enum.count()
    end
  end

  describe "filter_non_existent/1" do
    test "returns shorts that do not exist on the database" do
      insert(:url, short: "short11")
      insert(:url, short: "short22")

      assert ["short33"] == UrlShortner.filter_non_existent([%{short: "short33"}])
    end

    test "filter shorts that already exist on the database" do
      insert(:url, short: "short11")
      insert(:url, short: "short22")

      assert ["short33"] ==
               UrlShortner.filter_non_existent([%{short: "short22"}, %{short: "short33"}])
    end
  end
end
