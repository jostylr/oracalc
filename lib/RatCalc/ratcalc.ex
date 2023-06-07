defmodule Ratcalc do
  @moduledoc """
  Documentation for `Ratcalc`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Ratcalc.frac()
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

Ratcalc.frac(22, 7)
|> Ratcalc.fracString()
|> IO.puts()
