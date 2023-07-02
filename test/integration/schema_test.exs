defmodule WarlockTestApp.Repo do
  use Ecto.Repo, otp_app: :warlock, adapter: Ecto.Adapters.Postgres
end

defmodule WarlockTestApp.Schema do
  use Warlock.Schema

  schema "mocks" do
  end
end

defmodule WarlockTest.Integration.Schema do
  use ExUnit.Case

  test "filter_by_admin/1" do
    assert WarlockTestApp.Schema.filter_by_admin(:query) == :query
  end
end
