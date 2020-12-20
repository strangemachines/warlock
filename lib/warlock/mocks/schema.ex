defmodule Warlock.Mocks.Schema do
  @public_fields :public_fields
  @required_fields :required_fields

  use Warlock.Schema, repo: Warlock.Mocks.Repo

  schema "mock" do
  end
end
