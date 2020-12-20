defmodule Warlock.Mocks.Repo do
  def insert(changeset), do: {:ok, changeset}
end
