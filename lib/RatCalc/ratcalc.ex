defmodule Ratcalc do
  @undef {0, 0}
  @moduledoc """
  `Ratcalc` is a module that deals with fractional arithmetic. Its main purpose is to support Intercalc which does interval calculations with fractions.
  It can do the usual operations as well as compute averages, mediants, and reports a decimal version.
  """

  @typedoc """
  Fraction type as numerator, denominator and we do allow 0 denominators
  """
  @type frac :: {integer, integer}

  @spec newf(integer, integer) :: frac
  @doc """
  Frac creates a 2-tuple for a frac. It makes sure all denominators are non-negative. Zero is okay!
  """
  def newf(num, den) when den < 0, do: {-num, -den}
  def newf(num, den), do: {num, den}

  @spec print(frac, :tex) :: String.t()
  @doc """
  This converts a fraction tuple to a tex fraction string.
  """
  def print(f, :tex) do
    "\\frac\{#{elem(f, 0)}\}\{#{elem(f, 1)}\}"
  end

  @spec print(tuple) :: String.t()
  @doc """
  This converts a fraction tuple to a fraction string.
  """
  def print(f) do
    "#{elem(f, 0)} / #{elem(f, 1)}"
  end

  @spec add(frac, frac) :: frac
  @doc """
  adds two fractions together
  """
  def add({pn, pm}, {qn, qm}) when pm == 0 and qm == 0 and pn * qn <= 0, do: @undef
  def add({pn, pm}, {qn, qm}) when pm == qm, do: newf(pn + qn, pm)
  def add({pn, pm}, {qn, qm}), do: newf(pn * qm + qn * pm, pm * qm)

  @spec mul(frac, frac) :: frac
  @doc """
  multiplies two fractions together
  """
  def mul({pn, pm}, {qn, qm}) do
    newf(pn * qn, pm * qm)
  end

  @spec neg(frac) :: frac
  @doc """
  Negates a fraction
  """
  def neg({n, m}) do
    newf(-n, m)
  end

  @spec flip(frac) :: frac
  @doc """
  Reciprocates a fraction. Again we don't care about zeros so super easy.
  """
  def flip({n, m}) do
    newf(m, n)
  end

  @spec sub(frac, frac) :: frac
  @doc """
  Subtracts two fractions
  """
  def sub(p, q) do
    q
    |> neg()
    |> add(p)
  end

  @spec divf(frac, frac) :: frac
  @doc """
  Divides two fractions
  """
  def divf(p, q) do
    q
    |> flip()
    |> mul(p)
  end

  @spec reduce(frac) :: frac
  @doc """
  Reduce a fraction if common factors
  """
  def reduce({num, den}) do
    gcd = Integer.gcd(num, den)
    (gcd === 0 && @undef) || newf(div(num, gcd), div(den, gcd))
  end

  @spec scale(frac, integer) :: frac
  @doc """
  Scales a fraction's numerator and denominator by integer
  """
  def scale({num, den}, j) do
    newf(num * j, den * j)
  end

  @spec common(frac, frac) :: {frac, frac}
  @doc """
  Returns a tuple
  """
  def common({pn, pm}, {qn, qm}) do
    cd = Integer.gcd(pm, qm)

    if cd === 0 do
      {newf(pn, pm), newf(qn, qm)}
    else
      qcd = div(qm, cd)
      pcd = div(pm, cd)
      den = qcd * pm
      {newf(qcd * pn, den), newf(pcd * qn, den)}
    end
  end

  @spec average(frac, frac) :: frac
  @doc """
  Compute the average of two fractions by adding and dividing by 2
  """
  def average(p, q) do
    add(p, q)
    |> mul(newf(1, 2))
  end

  @spec average(list(frac)) :: frac
  @doc """
  Averages a list of fractions
  """
  def average(fracs) do
    {sum, n} =
      Enum.reduce(fracs, {newf(0, 1), 0}, fn frac, {acc, n} -> {add(frac, acc), n + 1} end)

    mul(sum, newf(1, n))
  end

  @spec mediant(frac, frac) :: frac
  @doc """
  Mediant adds the numerators and denominators to get a fraction in between.
  If using this with 0/0, the mediant returns the original which seems reasonable since it has nowhere else to go. For n/0, it adds n to the numerators, so inching towards the infinity in the denominator increments. Kind of nice.
  """
  def mediant({pn, pm}, {qn, qm}) do
    newf(pn + qn, pm + qm)
  end

  @spec to_decimal_string(frac, pos_integer(), atom()) :: String.t()
  @doc """
  This creates a decimal version of the frac up the number of specified decimal places. This one returns a decimal above the fraction. This is all text as we do not use the decimals for any computation. This makes division by zero easy to handle by being able to give a string representation of infinity
  """

  def to_decimal_string(frac, places, :gt) do
    to_decimal_string(frac, places, :ceiling)
  end

  def to_decimal_string(frac, places, :lt) do
    to_decimal_string(frac, places, :floor)
  end

  def to_decimal_string({num, den}, places \\ 5, type) do
    if den === 0 do
      cond do
        num > 0 ->
          "+Infinity"

        num < 0 ->
          "-Infinity"

        num === 0 ->
          "Indeterminate"
      end
    else
      Decimal.Context.with(%Decimal.Context{precision: places, rounding: type}, fn ->
        Decimal.div(num, den)
      end)
      |> Decimal.to_string(:raw)
    end
  end
end
