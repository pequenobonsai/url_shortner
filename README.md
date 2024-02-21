# UrlShortner
## Setup

1. You can use some tool like [`asdf`](https://asdf-vm.com) or [`mise`](https://github.com/jdx/mise) to install elixir and erlang.
1. Install postgres (can be `apt-get install` or `brew ienable nstall postgres`) and start it on the default port (`5432`)
    1. My bad for not setting up a docker-compose file, I don't use it so I wouldn't have a way to test it hehe
1. Run `mix setup` to install dependencies, setup the development database and run migrations

## Starting the server

Run `mix phx.server` or inside IEx with `iex -S mix phx.server`
Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Running tests

To run tests use `mix test`

:warning: Also added a [PROJECT.md](./PROJECT.md) file with some rationale behind decisions :warning:
