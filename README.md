# UrlShortner
## Setup

1. You can use some tool like [`asdf`](https://asdf-vm.com) or [`mise`](https://github.com/jdx/mise) to install elixir and erlang
    1. You can check versions used in `.tool-versions` but also in the `Dockerfile`
1. Install postgres (can be `apt-get install` or `brew install postgres`) and start it on the default port (`5432`)
    1. My bad for not setting up a docker-compose file, I don't use it that much but could come up with one if needed!
1. Run `mix setup` to install dependencies, setup the development database and run migrations

## Starting the server

Run `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Running tests

To run tests use `mix test`

:warning: Also added a [PROJECT.md](./PROJECT.md) file with some rationale behind decisions :warning:

## Running load testing

Wanted to try out `k6` so figured I could use this miniapp as an opportunity, keep in mind that load test scripts
are just to an _idea_ and were quickly hacked together, if this was a production setting would definitely spend
more time making something more maintainable.

If using `mise` or `asdf`, you can use the [k6 plugin](https://github.com/gr1m0h/asdf-k6), if not, the [main page](https://k6.io/open-source/) has installation instructions

To run start the server with `mix phx.server` then:

- `k6 run test/create_load_test.js`
- `k6 run test/redirect_load_test.js`

Both tests are independent.
