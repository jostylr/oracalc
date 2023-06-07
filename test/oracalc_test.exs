defmodule RatcalcTest do
  use ExUnit.Case
  doctest Ratcalc

  test "greets the world" do
    assert Ratcalc.hello() == :world
  end
end
