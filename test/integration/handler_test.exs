defmodule WarlockTestApp.Handler do
  use Warlock.Handler
end

defmodule WarlockTest.Integration.Handler do
  use ExUnit.Case

  test "filter_by_admin/1" do
    assert WarlockTestApp.Handler != nil
  end
end
