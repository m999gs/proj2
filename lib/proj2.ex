defmodule Proj2 do
  
  @moduledoc """
  Documentation for Proj2.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Proj2.hello()
      :world

  """
  def main(args \\ []) do
    startproject(args)
  end
  
  def startproject(args) do
    if length(args) >= 3 do
      [numNodes, topology, algorithm] = args
      numNodes = String.to_integer(numNodes)
      {:ok, _pid} = Proj2.Supervisor.start_link({self(), numNodes, topology, algorithm})
    else
        IO.puts("------You have invalid/missing argument(s)------")
        IO.puts("------numNodes : enter a number like 1000------")
        IO.puts("------topology : enter the topology  (full, line, rand2D, 3Dtorus, honeycomb, randhoneycomb)------")
        IO.puts("------algorithm : enter the algorithm (gossip or push-sum)------")
        System.halt(0)
    end
  end

  # defp output(timeSpent) do
  #   IO.puts "Duration: #{timeSpent} seconds"
  # end
end