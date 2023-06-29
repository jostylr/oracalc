import RationalCalculator.Fraction

list = Enum.to_list(1..10_000)
#map_fun = fn i -> [i, i * i] end

ft = new(7, 3)
fraclist = Enum.map(list, fn _ -> ft end)

twop = 1.0234

#a = Enum.reduce(list, new(5, 2), fn _, acc -> add(acc, new(7,3)) end)

#b = deci(a, :ceiling, 10)

#c = reduce(a)

#IO.puts(b)

#IO.puts(c)

Benchee.run(
  %{
    #"flat_map" => fn -> Enum.flat_map(list, map_fun) end,
    #"map.flatten" => fn -> list |> Enum.map(map_fun) |> List.flatten() end
    "frac_add" => fn -> Enum.reduce(list, new(5, 2), fn _, acc -> add(acc, acc) end) end,
    "frac_add 3" => fn -> Enum.reduce(list, new(5, 2), fn _, acc -> add(acc, ft) end) end,
    "frac_add new" => fn -> Enum.reduce(list, new(5, 2), fn _, acc -> add(acc, new(7,3)) end) end,
    "frac_quick_add" => fn -> sum(fraclist) end,
    "frac_quick_mul" => fn -> prod(fraclist) end,
    "decimal_add" => fn -> Enum.reduce(list, 3, fn _, acc -> (acc + twop) end) end,
    "decimal_mul" => fn -> Enum.reduce(list, 3, fn _, acc -> (acc * twop) end) end

  },
  warmup: 1,
  time: 5,
  memory_time: 2,
  reduction_time: 2
)
