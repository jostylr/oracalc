defmodule RationalCalculator.Fraction do
  @moduledoc """
  `Ratcalc` is a module that deals with fractional arithmetic. Its main purpose is to support Intercalc which does interval calculations with fractions.
  It can do the usual operations as well as compute averages, mediants, and reports a decimal version.
  """

  alias __MODULE__, as: Frac

  defstruct num: 0, den: 1

  @typedoc """
  Fraction type as numerator, denominator and we do allow 0 denominators
  """
  @type t :: %__MODULE__{
          num: integer,
          den: integer
        }

  @doc """
  Frac creates a 2-tuple for a frac. It makes sure all denominators are non-negative.

  A zero denominator is okay. It returns a numerator of 1 or -1, depending on the sign
  unles it numerator is 0 in which case we get or undefined of 0/0

  ## Examples

      iex> new(2, 3)
      %RationalCalculator.Fraction{num: 2, den: 3}

  Fractions are not reduced

      iex> new(27, 9)
      %RationalCalculator.Fraction{num: 27, den: 9}

  Zero is normalized to a denominator of 1

      iex> new(0, 7)
      %RationalCalculator.Fraction{num: 0, den: 1}

      Denominator of 0 is allowed and is normalized.

      iex> new(23, 0)
      %RationalCalculator.Fraction{num: 1, den: 0}

      iex> new(-12, 0)
      %RationalCalculator.Fraction{num: -1, den: 0}

      iex> new(0, 0)
      %RationalCalculator.Fraction{num: 0, den: 0}



  """
  @spec new(integer, integer) :: t
  def new(0, 0), do: %Frac{num: 0, den: 0}
  def new(0, _), do: %Frac{num: 0, den: 1}
  def new(num, den) when den < 0, do: %Frac{num: -num, den: -den}
  def new(num, 0) when num > 0, do: %Frac{num: 1, den: 0}
  def new(num, 0) when num < 0, do: %Frac{num: -1, den: 0}
  def new(num, den), do: %Frac{num: num, den: den}

  @doc """
  This converts a fraction tuple to a tex fraction string.

  ## Examples

      iex> print(new(2, 3), :tex)
      "\\frac{2}{3}"

      iex> print(new(12, -32), :tex)
      "\\frac{-12}{32}"


  """
  @spec print(t, :tex) :: String.t()
  def print(%Frac{num: n, den: d}, :tex) do
    "\frac{#{n}}{#{d}}"
  end

  @doc """
  This converts a fraction tuple to a fraction string.

  ## Examples

      iex> print(new(2,3))
      "2/3"

      iex> print(new(12, -32))
      "-12/32"

  """
  @spec print(t) :: String.t()
  def print(%Frac{num: n, den: d}) do
    "#{n}/#{d}"
  end

  @doc """
  Adds two fractions together. Unless the denominators are the same, the common denominator is
  them multiplied.

  If both denominators are zero and the numerators are of different sign (or 0) then the result
  is the undefined 0/0.

  ## Examples

        iex> add(new(2, 3), new(4, 5))
        new(22, 15)

        iex> add(new(-3, 7), new(10, 7))
        new(7, 7)

        iex> add(new(40, 3), new(-40, 3))
        new(0, 1)

        iex> add(new(5, 0), new(7, 3))
        new(1, 0)

        iex> add(new(5, 0), new(8, 0))
        new(1, 0)

        iex> add(new(5, 0), new(-7, 0))
        new(0,0)

  """
  @spec add(t, t) :: t
  # Because of the normalization of fractions with 0 denominators, no need for separate case
  # to handle positive and negative addition of /0; they automatically give 0/0
  def add(p = %Frac{}, q = %Frac{}) when p.den == q.den, do: new(p.num + q.num, p.den)
  def add(p = %Frac{}, q = %Frac{}), do: new(p.num * q.den + q.num * p.den, p.den * q.den)

  @doc """
  Multiplies two fractions together. No reductions for normal fractions.

  Zeros in the denominators continue along, though signs can change.

  ## Examples

      iex> mul(new(2, 3), new(4, 5))
      new(8, 15)

      iex> mul(new(-3, 7), new(10, 7))
      new(-30, 49)

      iex> mul(new(-3, 7), new(-7, 3))
      new(21, 21)

      iex> mul(new(5, 0), new(7, 3))
      new(1, 0)

      iex> mul(new(5, 0), new(-7, 3))
      new(-1, 0)

      iex> mul(new(5, 0), new(-7, 0))
      new(-1,0)

      iex> mul(new(5, 0), new(-7, 0))
      new(-1,0)
  """
  @spec mul(t, t) :: t
  def mul(p = %Frac{}, q = %Frac{}) do
    new(p.num * q.num, p.den * q.den)
  end

  @doc """
  Negates a fraction

  ## Examples

      iex> neg(new(3, 4))
      new(-3, 4)

      iex> neg(new(-3, 4))
      new(3, 4)

      iex> neg(new(1, 0))
      new(-1, 0)

      iex> neg(new(0, 1))
      new(0, 1)

      iex> neg(new(0,0))
      new(0,0)

  """
  @spec neg(t) :: t
  def neg(p = %Frac{}) do
    new(-p.num, p.den)
  end

  @spec flip(t) :: t
  @doc """
  Reciprocates a fraction.

  1/0 amd -1/0 map to 0.

  0/1 maps to 0/0 as we have lost sign info.

  ## Examples

      iex> flip(new(3,4))
      new(4,3)

      iex> flip(new(-23, 10))
      new(-10, 23)

      iex> flip(new(0, 1))
      new(0,0)

      iex> flip(new(1, 0))
      new(0,1)

      iex> flip(new(-1, 0))
      new(0, 1)

  """
  def flip(%Frac{num: 0}), do: new(0, 0)

  def flip(p = %Frac{}) do
    new(p.den, p.num)
  end

  @doc """
  Subtracts two fractions.

  ## Examples

      iex> sub(new(2, 3), new(4, 5))
      new(-2, 15)

      iex> sub(new(-3, 7), new(10, 7))
      new(-13, 7)

      iex> sub(new(40, 3), new(-40, 3))
      new(80, 3)

      iex> sub(new(40, 3), new(40, 3))
      new(0, 1)

      iex> sub(new(5, 0), new(7, 3))
      new(1, 0)

      iex> sub(new(5, 0), new(-7, 0))
      new(1,0)

      iex> sub(new(5, 0), new(7, 0))
      new(0,0)
  """
  @spec sub(t, t) :: t
  def sub(p = %Frac{}, q = %Frac{}) do
    q
    |> neg()
    |> add(p)
  end

  @doc """
  Divides two fractions.

  ## Examples

      iex> divf(new(2, 3), new(4, 5))
      new(10, 12)

      iex> divf(new(-3, 7), new(10, 7))
      new(-21, 70)

      iex> divf(new(-3, 7), new(-3, 7))
      new(21, 21)

      iex> divf(new(-3, 7), new(-7, 3))
      new(9, 49)

      iex> divf(new(5, 0), new(7, 3))
      new(1, 0)

      iex> divf(new(-7, 3), new(5, 0))
      new(0, 1)

      iex> divf(new(5, 0), new(-7, 0))
      new(0,0)
  """
  @spec divf(t, t) :: t
  def divf(p = %Frac{}, q = %Frac{}) do
    q
    |> flip()
    |> mul(p)
  end

  @doc """
  This finds the greatest common factor between numerator and denominator

  ## Examples

      iex> gcf(new(12, 8))
      4

  """
  @spec gcf(t) :: integer
  def gcf(p) do
    Integer.gcd(p.num, p.den)
  end

  @doc """
  A fraction can be reduced with a non-zero integer.

  The integer should divide into both numerator and denominator. Incorrect results will happen.

  By the way the new fraction creation works, having the integer be negative will
  not alter anything.

  If the integer is 0, we get undef

  ## Examples

      iex> reduce(new(24, 12), 2)
      new(12, 6)

      iex> reduce(new(24, 12), 0)
      new(0,0)

      Don't trust this if the factor is not common to both:

      iex> reduce(new(12, 5), 2)
      new(6, 2)
  """
  @spec reduce(t, integer) :: t
  def reduce(_, 0), do: %Frac{num: 0, den: 0}
  def reduce(p = %Frac{}, factor), do: new(div(p.num, factor), div(p.den, factor))

  @doc """
  Reduce a fraction if it has common factors of numerator and denominator

  ## Examples

      iex> reduce(new(12, 15))
      new(4, 5)

      iex> reduce(new(4, 4))
      new(1, 1)

      iex> reduce(new(5, 0))
      new(1, 0)

      iex> reduce(new(0,0))
      new(0,0)
  """
  @spec reduce(t) :: t
  def reduce(p = %Frac{}), do: reduce(p, Integer.gcd(p.num, p.den))

  @doc """
  Scales a fraction's numerator and denominator by an integer.

  Idempotent on normalized (0 and infinities)

  A negative scaling works but is not different than a positve scaling with the same magnitude

  ## Examples

      iex> scale(new(5,3), 2)
      new(10,6)

      iex> scale(new(4, 8), -3)
      new(12, 24)

  """
  @spec scale(t, integer) :: t
  def scale(p = %Frac{}, scalar), do: new(p.num * scalar, p.den * scalar)

  @doc """
  Compares two fractions and returns :gt, :lt, :unk,  or :eq depending on if the first
  one is greater than, less than, or equal to the second one.

  ## Examples

      iex> cmp(new(5, 3), new(7, 4))
      :lt

      iex> cmp(new(5, 3), new(10, 6))
      :eq

      iex> cmp(new(1, 3), new(-2, 3))
      :gt

      iex> cmp(new(3, 0), new(-2, 4))
      :gt

      iex> cmp(new(3, 0), new(-1, 0))
      :gt

      iex> cmp(new(3, 0), new(5, 0))
      :unk

      iex> cmp(new(0,0), new(4,7))
      :unk

  """
  @spec cmp(t, t) :: atom
  def cmp(p = %Frac{}, q = %Frac{})
      when (p.num == 0 and p.den === 0) or (q.num == 0 and q.den == 0) do
    :unk
  end

  # if they are of the same sign and both infinite, then comparison is unknown
  # if one is negative and the other is positive infinity, then we know
  def cmp(p = %Frac{}, q = %Frac{}) when p.den == 0 and q.den === 0 do
    cond do
      p.num * q.num > 0 -> :unk
      p.num > 0 -> :gt
      q.num > 0 -> :lt
    end
  end

  def cmp(p = %Frac{}, q = %Frac{}) do
    diff = p.num * q.den - q.num * p.den

    cond do
      diff > 0 -> :gt
      diff < 0 -> :lt
      diff == 0 -> :eq
    end
  end

  @doc """
  Returns true if the first fraction is greater than the second

  Indeterminants return false.

  ## Examples

      iex> gt?(new(3, 4), new(1, 3))
      true

      iex> gt?(new(-5,3), new(4,5))
      false

      iex> gt?(new(6,6), new(3,3))
      false

      iex> gt?(new(1, 0), new(100,1))
      true

      iex> gt?(new(0,0), new(2,3))
      false

  """
  @spec gt?(t, t) :: boolean
  def gt?(p = %Frac{}, q = %Frac{}) do
    res = cmp(p, q)

    if res == :gt do
      true
    else
      false
    end
  end

  @doc """
  Returns true if the first fraction is greater than or equal to the second

  Indeterminants return false.

  ## Examples

      iex> gte?(new(3, 4), new(1, 3))
      true

      iex> gte?(new(-5,3), new(4,5))
      false

      iex> gte?(new(6,6), new(3,3))
      true

      iex> gte?(new(1, 0), new(100,1))
      true

      iex> gte?(new(0,0), new(2,3))
      false
  """
  @spec gte?(t, t) :: boolean
  def gte?(p = %Frac{}, q = %Frac{}) do
    res = cmp(p, q)

    if res == :gt or res === :eq do
      true
    else
      false
    end
  end

  @doc """
  Returns true if the first fraction is less than the second

  Indeterminants return false.

  ## Examples

      iex> lt?(new(3, 4), new(1, 3))
      false

      iex> lt?(new(-5,3), new(4,5))
      true

      iex> lt?(new(6,6), new(3,3))
      false

      iex> lt?(new(1, 0), new(100,1))
      false

      iex> lt?(new(0,0), new(2,3))
      false


  """
  @spec lt?(t, t) :: boolean
  def lt?(p = %Frac{}, q = %Frac{}) do
    res = cmp(p, q)

    if res == :lt do
      true
    else
      false
    end
  end

  @doc """
  Returns true if the first fraction is less than or equal to the second

  Indeterminants return false.

  ## Examples

      iex> lte?(new(3, 4), new(1, 3))
      false

      iex> lte?(new(-5,3), new(4,5))
      true

      iex> lte?(new(6,6), new(3,3))
      true

      iex> lte?(new(1, 0), new(100,1))
      false

      iex> lte?(new(0,0), new(2,3))
      false


  """
  @spec lte?(t, t) :: boolean
  def lte?(p = %Frac{}, q = %Frac{}) do
    res = cmp(p, q)

    if res == :lt or res == :eq do
      true
    else
      false
    end
  end

  @doc """
  Returns true if the first fraction is equal to the second

  Indeterminants return false.

  ## Examples

      iex> eq?(new(3, 4), new(1, 3))
      false

      iex> eq?(new(-5,3), new(4,5))
      false

      iex> eq?(new(6,6), new(3,3))
      true

      iex> eq?(new(1, 0), new(1,0))
      false

      iex> eq?(new(0,0), new(0,0))
      false


  """
  @spec eq?(t, t) :: boolean
  def eq?(p = %Frac{}, q = %Frac{}) do
    res = cmp(p, q)

    if res == :eq do
      true
    else
      false
    end
  end

  @doc """
  Returns true if the comparison cannot be done.

  1/0 vs 1/0  and 0/0 are the main examples

  ## Examples

      iex> unk?(new(3, 4), new(1, 3))
      false

      iex> unk?(new(-5,0), new(-3,0))
      true

      iex> unk?(new(1,0), new(-1,0))
      false

      iex> unk?(new(1, 0), new(1,0))
      true

      iex> unk?(new(0,0), new(2,3))
      true


  """
  @spec unk?(t, t) :: boolean
  def unk?(p = %Frac{}, q = %Frac{}) do
    res = cmp(p, q)

    if res == :unk do
      true
    else
      false
    end
  end

  @doc """
  Returns scaled versions of the two fractions with the denominators having
  been converted to a common denominator.

  This uses the given denominators; no reduction is performed.

  ## Examples

      iex> common(new(5, 9), new(4, 6))
      {new(10, 18), new(12, 18)}

  """
  @spec common(t, t) :: {t, t}
  def common(p = %Frac{}, q = %Frac{}), do: common(p, q, Integer.gcd(p.den, q.den))

  # Cannot see a use for this so made it private.
  @spec common(t, t, integer) :: {t, t}
  defp common(p, q, 0), do: {p, q}

  defp common(p = %Frac{}, q = %Frac{}, fact) do
    qfact = div(q.den, fact)
    pfact = div(p.den, fact)
    den = qfact * p.den
    {new(qfact * p.num, den), new(pfact * q.num, den)}
  end

  @doc """
  Takes an fraction and an integer and raises the fraction to that power.

   ## Examples

    iex> pow(new(10,6), 7 )
    new(5**7, 3**7)

  """
  @spec pow(t, integer) :: t
  def pow(p = %Frac{num: 0, den: 0}, _), do: p
  # sends a/0 to 0/0 when raised to 0th power. the rest are 1 in a different form
  def pow(%Frac{den: d}, 0), do: new(d, d)
  def pow(p, exp) when exp < 0, do: pow(flip(p), -exp)

  def pow(p, exp) do
    p = reduce(p)
    new(p.num ** exp, p.den ** exp)
  end

  @doc """
  Sums up a list of fractions.
  Returns in reduced form along with number of summands

  ## Examples

      iex> sum([new(5,3), new(6,12), new(7, 10)])
      {new(43, 15), 3}

  """
  @spec sum(list(t)) :: {t, integer}
  def sum(fracs) do
    {num, den, n} =
      Enum.reduce(fracs, {0, 1, 0}, fn p, {num, den, n} ->
        {p.num * den + num * p.den, p.den * den, n + 1}
      end)

    {reduce(new(num, den)), n}
  end

  @doc """
  Compute the average of two fractions by adding and dividing by 2.

  This is not in reduced form.

  ## Examples

      iex> average(new(4, 3), new(6,4) )
      new(34, 24)

  """
  @spec average(t, t) :: t
  def average(p, q) do
    add(p, q)
    |> mul(new(1, 2))
  end

  @spec average(list(t)) :: t
  @doc """
  Averages a list of fractions.

  ## Examples

      iex> average([new(5,3), new(6,12), new(7, 10)])
      new(43, 45)

  """
  def average(fracs) do
    {total, n} = sum(fracs)
    mul(total, new(1, n))
  end

  @doc """
  Multiplies up a list of fractions.

  Returns in reduced form along with number of terms.

  ## Examples

      iex> prod([new(5,3), new(6,12), new(7, 10)])
      {new(7, 12), 3}

  """
  @spec prod(list(t)) :: {t, integer}
  def prod(fracs) do
    {num, den, n} =
      Enum.reduce(fracs, {1, 1, 0}, fn p, {num, den, n} ->
        {p.num * num, p.den * den, n + 1}
      end)

    {reduce(new(num, den)), n}
  end

  @doc """
  Mediant adds the numerators and denominators to get a fraction in between.

  If using this with 0/0, the mediant returns the original which seems reasonable since it
  has nowhere else to go. For n/0, it adds n to the numerators, so inching towards the infinity
  in the denominator increments. Kind of nice.

  ## Examples

      iex> mediant(new(3, 2), new(4, 3))
      new(7, 5)

      iex> mediant(new(5, 1), new(1,0))
      new(6,1)

      iex> mediant(new(7, 3), new(0, 0))
      new(7,3)

      iex> mediant( new(7, 3), new(-7, 3) )
      new(0, 3)

  """
  @spec mediant(t, t) :: t
  def mediant(p = %Frac{}, q = %Frac{}) do
    new(p.num + q.num, p.den + q.den)
  end

  @doc """
  This creates a decimal version of the fraction.

  The second parameter specifies how it should round. Use
  :gt to get a decimal greater than the fraciton and :lt to get one less than. One can also
  use the rounding type from the Decimal package.

  The decimal will go up to the number of specified decimal places, which
  is the optional third parameter.

  Use Decimal.to_string() to get a string version. Passing in :raw as 2nd argument yields
  a string of digits then E then power of 10 offset, mostly. The E portion may be missing.

  ## Examples

      iex> deci(new(10,3), :gt, 4)
      Decimal.new("3.334")

      iex> deci(new(10,3), :lt, 4) |> Decimal.to_string(:raw)
      "3333E-3"

      iex> deci(new(1,0), :gt, 4) |> Decimal.to_string()
      "Infinity"

      iex> deci(new(-1,0), :gt, 4) |> Decimal.to_string()
      "-Infinity"

      iex> deci(new(0,0), :gt, 4) |> Decimal.to_string()
      "NaN"

  """
  @spec deci(t, atom(), pos_integer()) :: Decimal.t()
  def deci(p, type, places \\ 5)
  def deci(p = %Frac{}, :gt, places), do: deci(p, :ceiling, places)
  def deci(p = %Frac{}, :lt, places), do: deci(p, :floor, places)
  def deci(%Frac{num: 0, den: 0}, _, _), do: Decimal.new("NaN")
  def deci(%Frac{num: n, den: 0}, _, _) when n > 0, do: Decimal.new("+Infinity")
  def deci(%Frac{num: n, den: 0}, _, _) when n < 0, do: Decimal.new("-Infinity")

  def deci(p = %Frac{}, type, places) do
    Decimal.Context.with(
      %Decimal.Context{precision: places, rounding: type},
      fn -> Decimal.div(p.num, p.den) end
    )
  end
end
