defmodule Ratcalc do
  @moduledoc """
  Documentation for `Ratcalc`.
  """

  @typedoc """
  Fraction type as numerator, denominator and we do allow 0 denominators
  """
  @type frac :: {integer, integer}

  @spec newf(integer, integer) :: frac
  @doc """
  Frac creates a 2-tuple for a frac. It makes sure all denominators are non-negative. Zero is okay!
  """
  def newf(num, den) do
    if den < 0 do
      {-num, -den}
    else
      {num, den}
    end
  end

  @spec print(tuple, :tex) :: String.t()
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
  def add({pn, pm}, {qn, qm}) do
    if pm == qm do
      newf(pn + qn, pm)
    else
      newf(pn * qm + qn * pm, pm * qm)
    end
  end

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
end
