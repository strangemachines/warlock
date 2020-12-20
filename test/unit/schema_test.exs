defmodule WarlockTest.Unit.Schema do
  use ExUnit.Case
  import Dummy

  alias Warlock.{Schema, ModuleUtils}

  test "pagination_offset/2" do
    assert Schema.pagination_offset("1", "20") == 0
  end

  test "pagination_offset/2 with page > 1" do
    assert Schema.pagination_offset("3", "20") == 40
  end

  test "repo_module/2" do
    dummy ModuleUtils, [{"slice_replace/2", :slice_replace}] do
      assert Schema.repo_module(:caller, nil) == :slice_replace
      assert called(ModuleUtils.slice_replace(:caller, "Repo"))
    end
  end

  test "repo_module/2 with a repo_module" do
    assert Schema.repo_module(:caller, :repo) == :repo
  end
end
