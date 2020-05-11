defmodule Optimus do
  @moduledoc """
  A collection of basic alghorithms for https://projecteuler.net/
  """

  @doc """
  Primes list up to N using Atkin's sieve

  ## Examples

      iex> Optimus.primes(1)
      []

      iex> Optimus.primes(2)
      [2]

      iex> Optimus.primes(3)
      [2, 3]

      iex> Optimus.primes(100)
      [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97]


  """
  def primes(m) when m < 2, do: []

  def primes(2), do: [2]

  def primes(3), do: [2, 3]

  def primes(m) do
    limit = trunc(:math.sqrt(m)) + 1
    sieve = :array.new(m + 1, {:default, false})

    inspect(limit)

    sieve =
      Enum.reduce(1..limit, sieve, fn x, sieve ->
        Enum.reduce(1..limit, sieve, fn y, sieve ->
          n = 4 * x * x + y * y

          sieve =
            if n <= m && (Integer.mod(n, 12) == 1 || Integer.mod(n, 12) == 5) do
              toggle_prime(sieve, n)
            else
              sieve
            end

          n = 3 * x * x + y * y

          sieve =
            if n <= m && Integer.mod(n, 12) == 7 do
              toggle_prime(sieve, n)
            else
              sieve
            end

          n = 3 * x * x - y * y

          sieve =
            if x > y && n <= m && Integer.mod(n, 12) == 11 do
              toggle_prime(sieve, n)
            else
              sieve
            end

          sieve
        end)
      end)

    sieve = :array.set(2, true, sieve)
    sieve = :array.set(3, true, sieve)

    sieve =
      Enum.reduce(5..limit, sieve, fn i, sieve ->
        current = :array.get(i, sieve)

        if current do
          reset_quadratics(sieve, m, i * i)
        else
          sieve
        end
      end)

    Enum.reduce(2..(m - 1), [], fn i, acc ->
      val = :array.get(i, sieve)

      if val do
        [i | acc]
      else
        acc
      end
    end)
    |> Enum.reverse()
  end

  defp toggle_prime(array, index) do
    current = :array.get(index, array)
    :array.set(index, !current, array)
  end

  defp reset_quadratics(array, n, i) when n < i do
    array
  end

  defp reset_quadratics(array, n, i) do
    :array.set(i, false, array)
    |> reset_quadratics(n, i * i)
  end
end
