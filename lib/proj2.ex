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
  def startproject() do
    if Enum.at(System.argv(),0) != nil and Enum.at(System.argv(),1) !=nil and Enum.at(System.argv(),2) != nil do
        [numNodes, topology, algorithm] = System.argv()
        {:ok, _pid} = Proj2.Supervisor.start_link({self(), numNodes, topology, algorithm})

    else
        IO.puts("------You have entered an invalid argument------")
        IO.puts("------please use only ($ mix run go.exs numNodes topology algorithm) format------")
        IO.puts("------numNodes : enter a number like 1000------")
        IO.puts("------topology : enter the topology  (full, line, rand2D, 3Dtorus, honeycomb, randhoneycomb)------")
        IO.puts("------algorithm : enter the algorithm (gossip or push-sum)------")
    end
  end

  # defp output(timeSpent) do
  #   IO.puts "Duration: #{timeSpent} seconds"
  # end
end