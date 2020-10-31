defmodule Warlock.Mocks.Handler do
  use Warlock.Handler

  def new(conn), do: conn

  def get(conn), do: conn

  def show(conn, _id), do: conn

  def edit(conn, _id), do: conn

  def delete(conn, _id), do: conn
end
