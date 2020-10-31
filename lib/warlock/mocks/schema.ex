defmodule Warlock.Mocks.Schema do
  use Warlock.Schema

  def new(_host, _params), do: {:ok, "new"}

  def get(_host, _params), do: ["get"]

  def by_id(_host, _id), do: {:ok, "by_id"}

  def edit(_host, _id, _params), do: {:ok, "edit"}

  def delete(_host, _id), do: {0, nil}
end
