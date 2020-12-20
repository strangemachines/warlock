defmodule Warlock.Schema do
  alias Ecto.{Changeset, Query, Schema}
  alias Warlock.ModuleUtils, as: Utils

  @doc """
  Calculates the pagination offset given the current page and items per page
  """
  def pagination_offset(page, items_per_page) do
    (String.to_integer(page) - 1) * String.to_integer(items_per_page)
  end

  def repo_module(caller_module, nil) do
    Utils.slice_replace(caller_module, "Repo")
  end

  def repo_module(_caller_module, repo_module), do: repo_module

  defmacro __using__(opts \\ []) do
    quote do
      name = unquote(opts[:name]) || unquote(Utils.atom_name(__CALLER__.module))
      alias unquote(Utils.slice_replace(__CALLER__.module, "Repo"))

      alias Ecto.Changeset

      import Ecto.Changeset
      import Ecto.Query
      import Warlock.Schema

      use Ecto.Schema

      key_type = Application.get_env(name, :primary_key_type, :binary_id)
      @primary_key {:id, key_type, autogenerate: true}
      @foreign_key_type key_type

      def validate_fields(item), do: item

      def changeset(item, payload) do
        schema = unquote(__CALLER__.module)

        item
        |> Changeset.cast(payload, @public_fields)
        |> Changeset.validate_required(@required_fields)
        |> schema.validate_fields()
      end

      def set_user(changeset, nil), do: changeset

      if !Enum.member?(excludes, :create) do
        def create(user_id, payload) do
          repo = unquote(repo_module(__CALLER__.module, opts[:repo]))
          schema = unquote(__CALLER__.module)

          struct(schema)
          |> schema.set_user(user_id)
          |> schema.changeset(payload)
          |> repo.insert()
        end

        defoverridable create: 2
      end

      defoverridable changeset: 2, set_user: 2, validate_fields: 1
    end
  end
end
