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
        [arg1,arg2,arg3] = System.argv()
        Proj2.Supervisor.init({arg1,arg2,arg3})

    else
        IO.puts("------You have entered an invalid argument------")
        IO.puts("------please use only ($ mix run go.exs arg1 arg2 arg3) format------")
        IO.puts("------arg1 : enter a number like 1000------")
        IO.puts("------arg2 : enter the topology  (full, line, rand2D, 3Dtorus, honeycomb, randhoneycomb)------")
        IO.puts("------arg3 : enter the algorithm (gossip, push-sum)------")
    end
  end
end