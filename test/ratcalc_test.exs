defmodule RatcalcTest do
  use ExUnit.Case
  doctest Ratcalc

  test "makes a fraction" do
    assert Ratcalc.frac(7, 22) == {7, 22}
  end
end
