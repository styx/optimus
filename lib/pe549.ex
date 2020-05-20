defmodule Pe549 do
  use Application

  @limit 100
  @limit floor(1.0e8)

  def start(_, _) do
    primes_sieve = Optimus.atkin_sieve(@limit)
    primes_list = Optimus.sieve_to_list(primes_sieve)

    :ets.new(:cache, [:ordered_set, :named_table])

    Enum.reduce(2..@limit, 0, fn i, acc ->
      if Integer.mod(i, 1000) == 0 do
        IO.binwrite(".")
      end

      acc +
        if Optimus.prime?(i, primes_sieve) do
          :ets.insert(:cache, {i, i})
          sp(i, i, i, i, i * i, @limit, i)
          i
        else
          best_factor(i, primes_list)
        end
    end)
  end

  def sp(_factorial_start, _result_start, _factorial, _result, power, limit, _i)
      when power > limit,
      do: nil

  def sp(factorial_start, result_start, factorial, result, power, limit, i) do
    result = result + i
    factorial = factorial * result
    factorial = Integer.mod(factorial, power)

    if Integer.mod(factorial, power) == 0 do
      :ets.insert(:cache, {power, result})
      sp(factorial_start, result_start, factorial_start, result_start, power * i, limit, i)
    else
      sp(factorial_start, result_start, factorial, result, power, limit, i)
    end
  end

  def best_factor(i, primes_list) do
    i
    |> Optimus.factorize(primes_list)
    |> Enum.map(fn {e, v} -> :math.pow(e, v) end)
    |> Enum.map(fn powered_factor ->
      [{_p, s}] = :ets.lookup(:cache, powered_factor)
      s
    end)
    |> Enum.max()
  end
end
