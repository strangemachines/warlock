defmodule WarlockTest.Mocks.Application do
  use ExUnit.Case
  import Dummy

  alias Warlock.Mocks.Application

  test "start/2" do
    children = [
      Warlock.Repo,
      {Plug.Cowboy,
       scheme: :http,
       plug: Warlock.Router,
       options: [port: 8000, compress: true]}
    ]

    dummy Supervisor, [{"start_link/2", :link}] do
      assert Application.start(1, 2) == :link

      assert called(
               Supervisor.start_link(children,
                 strategy: :one_for_one,
                 name: Warlock.Supervisor
               )
             )
    end
  end
end
