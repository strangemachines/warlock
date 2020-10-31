defmodule Warlock.Schema do
  alias Warlock.ModuleUtils
  alias Ecto.{Changeset, Query, Schema}

  @callback new(host :: String.t(), params :: %{}) ::
              {:ok, Schema.t()} | {:error, Changeset.t()}

  @callback get(host :: String.t(), params :: %{}) :: [Schema.t()]

  @doc """
  Used to perform count queries.
  """
  @callback get_count(user :: String.t(), params :: %{}) :: [Schema.t()]

  @callback by_id(host :: String.t(), id :: String.t()) ::
              {:ok, Schema.t()} | {:error, Query.CastError.t()}

  @callback edit(String.t(), String.t(), params :: %{}) ::
              {:ok, Schema.t()} | {:error, Changeset.t()}

  @callback delete(host :: String.t(), id :: String.t()) ::
              {integer(), nil | Query.CastError.t()}

  @optional_callbacks new: 2, get: 2, get_count: 2, by_id: 2, edit: 3, delete: 2

  defmacro __using__([]) do
    quote do
      alias unquote(ModuleUtils.slice_replace(__CALLER__.module, "Repo"))

      alias Ecto.Changeset

      import Ecto.Changeset
      import Ecto.Query

      use Ecto.Schema

      key_type = Application.get_env(:warlock, :primary_key_type, :binary_id)
      @primary_key {:id, key_type, autogenerate: true}
      @foreign_key_type key_type

      @behaviour Warlock.Schema
    end
  end
end
