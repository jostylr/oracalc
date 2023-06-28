defmodule RationalCalculator.FractionTest do
  import RationalCalculator.Fraction
  alias RationalCalculator.Fraction, as: Frac
  use ExUnit.Case
  doctest RationalCalculator.Fraction, import: true

  test "makes a fraction" do
    assert new(7, 22) == %Frac{num: 7, den: 22}
  end

  test "add two fractions" do
    assert add(new(2, 3), new(4, 5)) === new(22, 15)
  end

  test "easy fraction arithmetic" do
    p = new(2, 3)
    q = new(5, 7)
    assert(add(p, q) === new(29, 21))
    assert(mul(p, q) === new(10, 21))
    assert(neg(p) === new(-2, 3))
    assert(flip(p) === new(3, 2))
    assert(sub(p, q) === new(-1, 21))
    assert(divf(p, q) === new(14, 15))
  end

  test "reduce" do
    p = new(120, 48)
    q = new(0, 0)
    r = new(3, 0)
    assert(reduce(p) === new(5, 2))
    assert(reduce(q) === new(0, 0))
    assert(reduce(r) === new(1, 0))
  end

  test "signs" do
    p = new(-12, 3)
    q = new(12, -3)
    zz = new(0, 0)
    zn = new(0, -3)
    nz = new(-3, 0)
    assert(p === new(-12, 3))
    assert(q === new(-12, 3))
    assert(zz === new(0, 0))
    assert(zn === new(0, 3))
    assert(nz === new(-3, 0))
  end

  test "undef" do
    p = new(2, 0)
    q = new(-5, 0)
    assert add(p, q) === new(0, 0)
    assert mul(p, q) === new(-10, 0)
    assert flip(p) === new(0, 1)
  end

  test "average" do
    p = new(5, 6)
    q = new(7, 9)
    r = new(-3, 1)
    assert(average(p, q) === new(87, 108))
    assert(average([p, q, r]) === add(p, q) |> add(r) |> mul(new(1, 3)))
    assert(average([p, q, r]) === new(-75, 162))
  end

  test "mediant" do
    p = new(123, 7)
    q = new(32, -6)
    m = mediant(p, q)
    assert m === mediant(q, p)
    assert deci(m, 8, :gt) |> Decimal.to_string(:raw) === "7"
    assert mediant(m, q) === new(59, 19)
    assert deci(mediant(m, q), 8, :gt) |> Decimal.to_string(:raw) === "31052632E-7"
    assert deci(mediant(m, q), 8, :lt) |> Decimal.to_string(:raw) === "31052631E-7"
  end

  test "add/2" do
    assert add(new(2, 3), new(4, 6)) === new(24, 18)
    assert add(new(4, 6), new(-4, 6)) === new(0, 1)
    assert add(new(4, 6), new(-8, 6)) === new(-4, 6)
    assert add(new(-4, 6), new(-8, 6)) === new(-12, 6)
    assert add(new(4, 6), new(1, 0)) === new(1, 0)
    assert add(new(1, 0), new(-4, 0)) === new(0, 0)
    assert add(new(2, 3), new(-4, 0)) === new(-1, 0)
    assert add(new(2, 3), new(0, 0)) === new(0, 0)
    assert add(new(0, 0), new(0, 0)) === new(0, 0)
    assert add(new(43, 18), new(-123, 120)) === new(2946, 2160)
    assert add(new(-123, 120), new(5, -23)) === new(-3429, 2760)
    assert add(new(5, -23), new(-8, -12)) === new(124, 276)
  end

  test "mul/2" do
    assert mul(new(2, 3), new(4, 6)) === new(8, 18)
    assert mul(new(4, 6), new(6, 4)) === new(24, 24)
    assert mul(new(4, 6), new(-8, 6)) === new(-32, 36)
    assert mul(new(6, 4), new(-8, 6)) === new(-48, 24)
    assert mul(new(4, 6), new(1, 0)) === new(1, 0)
    assert mul(new(1, 0), new(-4, 0)) === new(-1, 0)
    assert mul(new(2, 3), new(-4, 0)) === new(-1, 0)
    assert mul(new(2, 3), new(0, 0)) === new(0, 0)
    assert mul(new(0, 0), new(0, 0)) === new(0, 0)
    assert mul(new(43, 18), new(-123, 120)) === new(-5289, 2160)
    assert mul(new(-123, 120), new(5, -23)) === new(615, 2760)
    assert mul(new(5, -23), new(-8, -12)) === new(-40, 276)
  end
end
