defmodule WarlockTest.ModuleUtils do
  use ExUnit.Case
  import Dummy

  alias Warlock.ModuleUtils

  test "name/1" do
    dummy Module, [{"split", [:split]}] do
      assert ModuleUtils.name("App.Module") == :split
      assert called(Module.split("App.Module"))
    end
  end

  test "atom_name/1" do
    dummy ModuleUtils, [{"name", "Name"}] do
      assert ModuleUtils.atom_name("App.Module") == :name
      assert called(ModuleUtils.name("App.Module"))
    end
  end

  test "replace_at/2" do
    dummy Module, [{"concat", :concat}, {"split", ["App", "Module"]}] do
      assert ModuleUtils.replace_at("App.Module", "Another") == :concat
      assert called(Module.split("App.Module"))
      assert called(Module.concat(["App", "Another"]))
    end
  end

  test "replace_at/3" do
    dummy Module, [{"concat", :concat}, {"split", ["App", "Module"]}] do
      assert ModuleUtils.replace_at("App.Module", "Another", 0) == :concat
      assert called(Module.split("App.Module"))
      assert called(Module.concat(["Another", "Module"]))
    end
  end

  test "slice_replace/2" do
    dummy Module, [{"concat", :concat}, {"split", ["App", "Module", "Sub"]}] do
      assert ModuleUtils.slice_replace("App.Module.Sub", "Another") == :concat
      assert called(Module.split("App.Module.Sub"))
      assert called(Module.concat(["App", "Another"]))
    end
  end

  test "slice_replace/3" do
    dummy Module, [{"concat", :concat}, {"split", ["App", "Module", "Sub"]}] do
      assert ModuleUtils.slice_replace("App.Module.Sub", "New", 0) == :concat

      assert called(Module.split("App.Module.Sub"))
      assert called(Module.concat(["New", "Module"]))
    end
  end
end
