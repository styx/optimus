defmodule Optimus do
  @moduledoc """
  A collection of basic alghorithms for https://projecteuler.net/
  """

  @doc """
  Primes list up to N using Atkin's sieve

  ## Examples

  iex> Optimus.atkin(1)
  []

  iex> Optimus.atkin(2)
  [2]

  iex> Optimus.atkin(3)
  [2, 3]

  iex> Optimus.atkin(100)
  [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97]

  """

  def atkin(m) when m < 2, do: []

  def atkin(2), do: [2]

  def atkin(3), do: [2, 3]

  def atkin(m) do
    m
    |> atkin_sieve
    |> sieve_to_list
  end

  def sieve_to_list(sieve) do
    Enum.reduce(2..(:array.size(sieve) - 1), [], fn i, acc ->
      val = :array.get(i, sieve)

      if val do
        [i | acc]
      else
        acc
      end
    end)
    |> Enum.reverse()
  end

  def atkin_sieve(m) do
    limit = trunc(:math.sqrt(m)) + 1
    sieve = :array.new(m + 1, {:default, false})

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

    Enum.reduce(5..limit, sieve, fn i, sieve ->
      current = :array.get(i, sieve)

      if current do
        reset_quadratics(sieve, m, i * i)
      else
        sieve
      end
    end)
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

  def prime?(n, primes_sieve) do
    :array.get(n, primes_sieve) == true
  end

  @doc """
  Factorize number

  ## Examples

  iex> Optimus.factorize(1)
  %{}

  iex> Optimus.factorize(2)
  %{2 => 1}

  iex> Optimus.factorize(4)
  %{2 => 2}

  iex> Optimus.factorize(8)
  %{2 => 3}

  iex> Optimus.factorize(10)
  %{2 => 1, 5 => 1}

  iex> Optimus.factorize(125)
  %{5 => 3}
  """

  def factorize(n) do
    primes =
      n
      |> div(2)
      |> Kernel.+(1)
      |> atkin

    do_factorize(n, n, primes, %{})
  end

  def factorize(n, big_list_of_primes) do
    limit =
      n
      |> div(2)
      |> Kernel.+(1)

    primes = Enum.take_while(big_list_of_primes, fn prime -> prime <= limit end)
    do_factorize(n, n, primes, %{})
  end

  @spec do_factorize(integer, integer, [any()] | [], %{integer => integer}) :: %{
          integer => integer
        }
  defp do_factorize(1, _n, _primes, factors), do: factors

  defp do_factorize(_current_n, n, [], factors) when map_size(factors) == 0, do: %{n => 1}

  defp do_factorize(current_n, _n, [], factors) do
    {_, new_factors} =
      Map.get_and_update(factors, current_n, fn power ->
        {power, (power || 0) + 1}
      end)

    new_factors
  end

  defp do_factorize(current_n, n, [prime | rest_primes] = primes, factors) do
    if Integer.mod(current_n, prime) == 0 do
      {_, new_factors} =
        Map.get_and_update(factors, prime, fn power ->
          {power, (power || 0) + 1}
        end)

      current_n
      |> div(prime)
      |> do_factorize(n, primes, new_factors)
    else
      do_factorize(current_n, n, rest_primes, factors)
    end
  end
end
