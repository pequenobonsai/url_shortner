defmodule UrlShortner.KeyGeneratorTest do
  use ExUnit.Case, async: true

  alias UrlShortner.KeyGenerator

  test "generates a few keys on startup" do
    assert %{count: count, keys: keys} = KeyGenerator.state()

    assert count > 0
    assert Enum.count(keys) > 0
    assert count == Enum.count(keys)
  end

  test "can consume a key" do
    state = KeyGenerator.state()
    key = KeyGenerator.generate()
    new_state = KeyGenerator.state()

    assert key != ""
    assert new_state.count < state.count
    assert Enum.count(new_state.keys) < Enum.count(state.keys)
  end

  @tag skip: true
  test "tries to refill every X time"

  @tag skip: true
  test "refills if count goes below the amount"
end
