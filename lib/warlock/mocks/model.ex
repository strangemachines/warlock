if Code.ensure_loaded?(Ecto) do
  defmodule Warlock.Mocks.Model do
    use Warlock.Model, schema: Warlock.Mocks.Schema
  end
else
  defmodule Warlock.Mocks.Model do
  end
end
