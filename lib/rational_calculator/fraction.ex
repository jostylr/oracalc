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

    iex> add(new(5, 0), new(7, 3))
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

  iex> mul(new(2, 3), new(4, 5))
  new(8, 15)

  iex>


  """
  @spec mul(t, t) :: t
  def mul(p = %Frac{}, q = %Frac{}) do
    new(p.num * q.num, p.den * q.den)
  end

  @doc """
  Negates a fraction
  """
  @spec neg(t) :: t
  def neg(p = %Frac{}) do
    new(-p.num, p.den)
  end

  @spec flip(t) :: t
  @doc """
  Reciprocates a fraction. Again we don't care about zeros so super easy.
  """
  def flip(p = %Frac{}) do
    new(p.den, p.num)
  end

  @doc """
  Subtracts two fractions
  """
  @spec sub(t, t) :: t
  def sub(p = %Frac{}, q = %Frac{}) do
    q
    |> neg()
    |> add(p)
  end

  @doc """
  Divides two fractions
  """
  @spec divf(t, t) :: t
  def divf(p = %Frac{}, q = %Frac{}) do
    q
    |> flip()
    |> mul(p)
  end

  @doc """
  A fraction can be reduced with a non-zero integer. The integer should divide into both numerator and denominator. Errors will result otherwise. By the way the new works, having the integer be negative will not alter anything. If the integer is 0, we get undef
  """
  @spec reduce(t, integer) :: t
  def reduce(_, 0), do: %Frac{num: 0, den: 0}
  def reduce(p = %Frac{}, fact), do: new(div(p.num, fact), div(p.den, fact))

  @doc """
  Reduce a fraction if common factors
  """
  @spec reduce(t) :: t
  def reduce(p = %Frac{}), do: reduce(p, Integer.gcd(p.num, p.den))

  @doc """
  Scales a fraction's numerator and denominator by integer
  """
  @spec scale(t, integer) :: t
  def scale(p = %Frac{}, scalar), do: new(p.num * scalar, p.den * scalar)

  @doc """
  Returns a tuple
  """
  @spec common(t, t) :: {t, t}
  def common(p = %Frac{}, q = %Frac{}), do: common(p, q, Integer.gcd(p.den, q.den))

  @spec common(t, t, integer) :: {t, t}
  defp common(p, q, 0), do: {p, q}

  defp common(p = %Frac{}, q = %Frac{}, fact) do
    qfact = div(q.den, fact)
    pfact = div(p.den, fact)
    den = qfact * p.den
    {new(qfact * p.num, den), new(pfact * q.num, den)}
  end

  @doc """
  Compute the average of two fractions by adding and dividing by 2
  """
  @spec average(t, t) :: t
  def average(p, q) do
    add(p, q)
    |> mul(new(1, 2))
  end

  @spec average(list(t)) :: t
  @doc """
  Averages a list of fractions
  """
  def average(fracs) do
    {sum, n} =
      Enum.reduce(fracs, {%Frac{num: 0, den: 1}, 0}, fn frac, {acc, n} ->
        {add(frac, acc), n + 1}
      end)

    mul(sum, new(1, n))
  end

  @doc """
  Mediant adds the numerators and denominators to get a fraction in between.
  If using this with 0/0, the mediant returns the original which seems reasonable since it has nowhere else to go. For n/0, it adds n to the numerators, so inching towards the infinity in the denominator increments. Kind of nice.
  """
  @spec mediant(t, t) :: t
  def mediant(p = %Frac{}, q = %Frac{}) do
    new(p.num + q.num, p.den + q.den)
  end

  @doc """
  This creates a decimal version of the frac up the number of specified decimal places.



  Use :gt in the thrid parameter
   This is all text as we do not use the decimals for any computation. This makes division by zero easy to handle by being able to give a string representation of infinity
  """
  @spec deci(t, pos_integer(), atom()) :: Decimal.t()
  def deci(p, places \\ 5, type)
  def deci(p = %Frac{}, places, :gt), do: deci(p, places, :ceiling)
  def deci(p = %Frac{}, places, :lt), do: deci(p, places, :floor)
  def deci(%Frac{num: 0, den: 0}, _, _), do: Decimal.new("NaN")
  def deci(%Frac{num: n, den: 0}, _, _) when n > 0, do: Decimal.new("+Infinity")
  def deci(%Frac{num: n, den: 0}, _, _) when n < 0, do: Decimal.new("-Infinity")

  def deci(p = %Frac{}, places, type) do
    Decimal.Context.with(
      %Decimal.Context{precision: places, rounding: type},
      fn -> Decimal.div(p.num, p.den) end
    )
  end
end
