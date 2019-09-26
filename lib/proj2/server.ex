defmodule Proj2.Server do
    use GenServer
    
    def init(x) do
      # IO.inspect x
      {arg1,arg2,arg3}=x
      IO.puts(arg1<>"  "<>arg2<>"  "<>arg3);
      {:ok, x}
    end

end