defmodule OracalcTest do
  use ExUnit.Case
  doctest Oracalc

  test "greets the world" do
    assert Oracalc.hello() == :world
  end
end
