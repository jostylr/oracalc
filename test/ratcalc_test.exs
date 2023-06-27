defmodule RatcalcTest do
  import Ratcalc
  use ExUnit.Case
  doctest Ratcalc

  test "makes a fraction" do
    assert newf(7, 22) == {7, 22}
  end

  test "add two fractions" do
    assert add(newf(2, 3), newf(4, 5)) === {22, 15}
  end

  test "easy fraction arithmetic" do
    p = newf(2, 3)
    q = newf(5, 7)
    assert(add(p, q) === {29, 21})
    assert(mul(p, q) === {10, 21})
    assert(neg(p) === {-2, 3})
    assert(flip(p) === {3, 2})
    assert(sub(p, q) === {-1, 21})
    assert(divf(p, q) === {14, 15})
  end
end
