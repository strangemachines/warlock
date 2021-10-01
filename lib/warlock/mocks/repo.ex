defmodule Warlock.Mocks.Repo do
  def insert(changeset), do: changeset
  def update(changeset), do: changeset
  def all(query), do: query
  def delete_all(query), do: query
end
