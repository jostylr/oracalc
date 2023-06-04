defmodule Oracalc do
  @moduledoc """
  Documentation for `Oracalc`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Oracalc.frac()
      :world

  """
  def frac(num, den) when den > 0 do
    {:ok, num, den}
  end

  def frac(_num, den) do
    {:error, "Need a positive denominator", den}
  end

  def fracString(frac) do
    "#{elem(frac, 1)} / #{elem(frac, 2)}"
  end
end

Oracalc.frac(22, 7)
|> Oracalc.fracString()
|> IO.puts()
