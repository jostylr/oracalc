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

  test "reduce" do
    p = newf(120, 48)
    q = newf(0, 0)
    r = newf(3, 0)
    assert(reduce(p) === {5, 2})
    assert(reduce(q) === {0, 0})
    assert(reduce(r) === {1, 0})
  end

  test "signs" do
    p = newf(-12, 3)
    q = newf(12, -3)
    zz = newf(0, 0)
    zn = newf(0, -3)
    nz = newf(-3, 0)
    assert(p === {-12, 3})
    assert(q === {-12, 3})
    assert(zz === {0, 0})
    assert(zn === {0, 3})
    assert(nz === newf(-3, 0))
  end

  test "undef" do
    p = newf(2, 0)
    q = newf(-5, 0)
    assert add(p, q) === {0, 0}
    assert mul(p, q) === {-10, 0}
    assert flip(p) === {0, 2}
  end

  test "average" do
    p = newf(5, 6)
    q = newf(7, 9)
    r = newf(-3, 1)
    assert(average(p, q) === newf(87, 108))
    assert(average([p, q, r]) === add(p, q) |> add(r) |> mul(newf(1, 3)))
    assert(average([p, q, r]) === newf(-75, 162))
  end

  test "mediant" do
    p = newf(123, 7)
    q = newf(32, -6)
    m = mediant(p, q)
    assert m === mediant(q, p)
    assert to_decimal_string(m, 8, :gt) === "7"
    assert mediant(m, q) === {59, 19}
    assert to_decimal_string(mediant(m, q), 8, :gt) === "31052632E-7"
    assert to_decimal_string(mediant(m, q), 8, :lt) === "31052631E-7"
  end
end
