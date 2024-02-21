Mox.defmock(KeyGeneratorMock, for: UrlShortner.KeyGenerator)
Application.put_env(:url_shortner, :key_generator, KeyGeneratorMock)

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(UrlShortner.Repo, :manual)
{:ok, _} = Application.ensure_all_started(:ex_machina)
Faker.start()
