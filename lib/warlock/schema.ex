defmodule Warlock.Schema do
  alias Warlock.ModuleUtils
  alias Ecto.{Changeset, Query, Schema}

  @doc """
  Calculates the pagination offset given the current page and items per page
  """
  def pagination_offset(page, items_per_page) do
    (String.to_integer(page) - 1) * String.to_integer(items_per_page)
  end

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

      def validate_fields(item), do: item

      defoverridable validate_fields: 1
    end
  end
end
