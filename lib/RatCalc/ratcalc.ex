defmodule Ratcalc do
  @moduledoc """
  Documentation for `Ratcalc`.
  """

  @spec frac(integer(), integer()) :: {integer(), integer()}
  @doc """
  Frac creates a 2-tuple for a frac. That's all.
  """
  def frac(num, den) do
    {num, den}
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
end

Ratcalc.frac(22, 9)
|> Ratcalc.fracString()
|> IO.puts()
