defmodule Warlock.Mocks.JsonHandler do
  use Warlock.Handler

  alias Warlock.Mocks.JsonHandler

  def new(conn), do: JsonHandler.send_201(conn, :payload)

  def get(conn), do: JsonHandler.send_200(conn, :payload)

  def show(conn, _id), do: conn

  def edit(conn, _id), do: conn

  def delete(conn, _id), do: JsonHandler.send_204(conn)
end
