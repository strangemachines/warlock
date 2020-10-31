defmodule Warlock.Controller do
  alias Warlock.ModuleUtils
  alias Ecto.{Changeset, Query, Schema}

  @callback new(host :: String.t(), params :: %{}) ::
              {:ok, Schema.t()} | {:error, Changeset.t()}

  @callback get(host :: String.t(), params :: %{}) ::
              {:ok, Schema.t()} | {:error, Changeset.t()}

  @callback by_id(host :: String.t(), id :: String.t()) ::
              {:ok, Schema.t()} | {:error, Query.CastError.t()}

  @callback edit(String.t(), String.t(), params :: %{}) ::
              {:ok, Schema.t()} | {:error, Changeset.t()}

  @callback delete(host :: String.t(), id :: String.t()) ::
              {integer(), nil | Query.CastError.t()}

  @optional_callbacks new: 2, get: 2, by_id: 2, edit: 3, delete: 2

  defmacro __using__([]) do
    quote do
      alias unquote(ModuleUtils.slice_replace(__CALLER__.module, "Repo"))
      alias unquote(ModuleUtils.replace_at(__CALLER__.module, "Schemas"))

      @behaviour Warlock.Controller
    end
  end
end
