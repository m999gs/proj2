defmodule Proj2.Server do
    use GenServer
    
    def init(x) do
      {:ok, x}
    end
end