defmodule Proj2.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Proj2.Worker.start_link(arg)
      # {Proj2.Worker, arg}
    ]

    opts = [strategy: :one_for_one, name: Proj2.Supervisor]
    Supervisor.start_link(children, opts)
    # Proj2.Supervisor.start_link(self())   #calls the supervisor with its pid, not working currently
  end
end
