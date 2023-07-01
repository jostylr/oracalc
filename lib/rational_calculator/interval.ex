defmodule RationalCalculator.Interval do
  @moduledoc """
  This does interval arithmetic including methods for reals as oracles.

  If we know that a is between 2/3,5/4 while b is between 9/2,10/2, then
  we can add them to know that a+b is between 31/6,25/4. If the first two
  were precise bounds, then this is as well.

  For us, all intervals will be inclusive of the endpoints. We also allow
  intervals that are singletons, represented by having the same fraction for
  both endpoints.

  The fundamental data structure is a struct of the lower endpoint, upper endpoint,
  and a four place decimal length.

  """

  alias RationalCalculator.Fraction, as: Frac
  alias __MODULE__, as: Ival

  require Integer

  defstruct [:lower, :upper, :length]

  @type t :: %__MODULE__{
          lower: Frac.t(),
          upper: Frac.t(),
          length: Decimal.t()
        }

  @doc """
  This creates an interval given two fractions.

  ## Examples

      iex> new(Frac.new(9, 15), Frac.new(1, 1))
      %Ival{ lower: Frac.new(3,5), upper: Frac.new(1, 1), length: Decimal.new("0.4")}

      iex> new(-2, 3, -5, 6)
      %Ival{ lower: Frac.new(-5,6), upper: Frac.new(-2, 3), length: Decimal.new("0.1667")}

  """
  @spec new(Frac.t(), Frac.t()) :: t
  def new(p, q) do
    p = Frac.reduce(p)
    q = Frac.reduce(q)
    new(p, q, Frac.cmp(p, q))
  end

  @doc """
  This is when we know the ordering. The 2-arity uses them after computing it.

  The third parameter indicates the relation.

  :rlt option as third pararmeter says the lower one is first, but we should reduce as well

  ## Examples

      iex> new(Frac.new(5,7), Frac.new(4,3), :lt)
      %Ival{ lower: Frac.new(5,7), upper: Frac.new(4, 3), length: Decimal.new("0.6191")}


  """
  @spec new(Frac.t(), Frac.t(), atom) :: t
  def new(p, _, :eq), do: %Ival{lower: p, upper: p, length: 0}
  def new(p, q, :unk), do: %Ival{lower: p, upper: q, length: Decimal.new("+Infinity")}
  def new(p, q, :lt), do: %Ival{lower: p, upper: q, length: Frac.distance(q, p)}
  # For when we know the order, but still need to reduce, mainly arithmetic operations we track.
  def new(p, q, :rlt),
    do: %Ival{lower: Frac.reduce(p), upper: Frac.reduce(q), length: Frac.distance(q, p)}

  def new(p, q, :gt), do: %Ival{lower: q, upper: p, length: Frac.distance(p, q)}

  @doc """
  This is a shorthand way to create an interval of fractions used for examples

  It takes 4 integers and converts them into endpoint fractions.

  ## Examples

      iex> new(4, 3, 5, 7)
      %Ival{ lower: Frac.new(5,7), upper: Frac.new(4, 3), length: Decimal.new("0.6191")}

  """
  @spec new(integer, integer, integer, integer) :: t
  def new(pnum, pden, qnum, qden), do: new(Frac.new(pnum, pden), Frac.new(qnum, qden))

  @doc """
  This adds two intervals.

  ## Examples

      iex> add(new(2, 3, 5, 6), new(4, 3, 8, 2))
      new(2, 1, 29, 6)

  """
  @spec add(t, t) :: t
  # the intervals are ordered so we just add the lower and upper ones
  def add(a, b), do: new(Frac.add(a.lower, b.lower), Frac.add(a.upper, b.upper), :rlt)

  @doc """
  This negates an interval.

  ## Examples

      iex> neg(new(2, 3, 5, 6))
      new(-5, 6, -2, 3)

  """
  @spec neg(t) :: t
  def neg(a), do: new(Frac.neg(a.upper), Frac.neg(a.lower), :lt)

  @doc """
  This subtracts two intervals.

  ## Examples

      iex> sub(new(2, 3, 5, 6), new(4, 3, 8, 2))
      new(-10, 3, -3, 6)

  """
  @spec sub(t, t) :: t
  def sub(a, b), do: new(Frac.sub(a.lower, b.upper), Frac.sub(a.upper, b.lower), :rlt)

  # TODO: Multiply is only working right for positive.
  @doc """
  This multiply two intervals.

  ## Examples

      iex> mul(new(2, 3, 5, 6), new(4, 3, 8, 2))
      new(8, 9, 10, 3)

      iex> mul(new(-2, 3, -5, 6), new(-4, 3, -8, 2))
      new(8, 9, 10, 3)

      iex> mul(new(-2, 3, 5, 6), new(4, 3, 8, 2))
      new(-8, 3, 10, 3)

  """
  @spec mul(t, t) :: t
  def mul(a, b) when a.lower.num > 0 and b.lower.num > 0,
    do: new(Frac.mul(a.lower, b.lower), Frac.mul(a.upper, b.upper), :rlt)

  def mul(a, b) when a.upper.num < 0 and b.upper.num < 0,
    do: new(Frac.mul(a.upper, b.upper), Frac.mul(a.lower, b.lower), :rlt)

  # 0 is contained in the interval, need to check cases
  def mul(a, b) do
    temp = Frac.mul(a.lower, b.lower)

    {max, min} =
      {temp, temp}
      |> mulhelper(a.upper, b.upper)
      |> mulhelper(a.upper, b.lower)
      |> mulhelper(a.lower, b.upper)

    new(min, max, :rlt)
  end

  defp mulhelper({max, min}, p, q) do
    prod = Frac.mul(p, q)
    {Frac.maxf(max, prod), Frac.minf(min, prod)}
  end

  @doc """
  This reciprocates an interval.

  ## Examples

      iex> flip(new(2, 3, 5, 6))
      new(6, 5, 3, 2)

      iex> flip(new(-1, 2, 4, 3))
      new(-1, 0, 1, 0)

  """
  @spec flip(t) :: t
  # 0 is in the interval:
  def flip(a) when a.lower.num * a.upper.num <= 0, do: new(-1, 0, 1, 0)
  def flip(a), do: new(Frac.flip(a.upper), Frac.flip(a.lower), :lt)

  @doc """
  This divides the two intervals.

  ## Examples

      iex> divi(new(2, 3, 5, 6), new(4, 3, 8, 2))
      new(1, 6, 5, 8)

      iex> divi(new(2, 3, 5, 6), new(-1, 2, 3, 3))
      new(0, 0, 0, 0)

  """
  @spec divi(t, t) :: t
  def divi(a, b), do: mul(a, flip(b))

  @doc """
  Raises an interval to a power.

  This is not the same as repeated multiplying an interval as that would multiply
  differing elements in the interval.

  ## Examples

      iex> pow(new(4, 3, 3, 2), 2)
      new(16, 9, 9, 4)

      iex> pow(new(-1, 2, 1, 3), 2)
      new(0, 1, 1, 4 )

  """
  @spec pow(t, integer) :: t
  def pow(x, n)
      when x.lower.num > 0 or (x.upper.num < 0 and Integer.is_odd(n)),
      do: new(Frac.pow(x.lower, n), Frac.pow(x.upper, n), :lt)

  def pow(x, n)
      when x.upper.num < 0 and Integer.is_even(n),
      do: new(Frac.pow(x.lower, n), Frac.pow(x.upper, n), :gt)

  # mixed signs
  def pow(x, n) when Integer.is_even(n) do
    lowabs = Frac.new(-x.lower.num, x.lower.den)
    m = Frac.maxf(lowabs, x.upper)
    new(Frac.new(0, 1), Frac.pow(m, n), :lt)
  end
end
