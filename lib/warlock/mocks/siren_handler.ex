defmodule Warlock.Mocks.SirenHandler do
  use Warlock.Handler, response_type: :siren

  alias Warlock.Mocks.SirenHandler

  def new(conn), do: SirenHandler.send_201(conn, :payload)

  def get(conn), do: SirenHandler.send_200(conn, :payload)
  def get(conn, count), do: SirenHandler.send_200(conn, :payload, count)
end
