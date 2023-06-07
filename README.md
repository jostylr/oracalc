# Rational Math Calculator

RatCalc is a rational math calculator for Elixir. It is a stand-alone library whose goal is to implement a real-number arithmetic based on rational intervals as replacements for decimals. See [Reals as Oracles](https://github.com/jostylr/Reals-as-Oracles) for the mathematical background for this idea.

Essentially, this implements an arithmetic of fractions which then, when coupled with rational interval representation of real numbers, becomes a real number calculator.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `oracalc` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:oracalc, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/oracalc>.
