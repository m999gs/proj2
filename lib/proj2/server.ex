defmodule Proj2.Server do
    use GenServer
    
    def init(x) do
      # IO.inspect x
      {:ok, x}
    end
end