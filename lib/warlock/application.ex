defmodule Warlock.Application do
  alias Warlock.ModuleUtils, as: Utils

  defmacro __using__(opts \\ []) do
    quote do
      use Application
      require Logger

      name = unquote(Utils.name_or_option(__CALLER__.module, opts[:name]))

      @port Application.get_env(name, :port)

      def start(_type, _args) do
        repo = unquote(Utils.slice_replace(__CALLER__.module, "Repo"))
        router = unquote(Utils.slice_replace(__CALLER__.module, "Router"))

        supervisor =
          unquote(Utils.slice_replace(__CALLER__.module, "Supervisor"))

        children = [
          repo,
          {Plug.Cowboy,
           scheme: :http, plug: router, options: [port: @port, compress: true]}
        ]

        module = unquote(Utils.name(__CALLER__.module))
        Logger.info("#{module} started on port #{@port}")

        Supervisor.start_link(children, strategy: :one_for_one, name: supervisor)
      end
    end
  end
end
