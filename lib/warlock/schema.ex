if Code.ensure_loaded?(Ecto) do
  defmodule Warlock.Schema do
    alias Ecto.{Changeset, Schema}
    alias Warlock.ModuleUtils, as: Utils

    @type user() :: atom() | String.t()
    @type query_result() :: {:ok, Schema.t()} | {:error, Changeset.t()}

    @callback new(params :: map(), user :: user()) :: query_result()
    @callback get(params :: map(), user :: user()) :: query_result()
    @callback get_count(params :: map(), user :: user()) :: query_result()
    @callback show(id :: any(), user :: user()) :: query_result()
    @callback update(item :: Schema.t(), params :: map()) :: query_result()
    @callback edit(params :: map(), id :: any(), user :: user()) ::
                query_result()
    @callback delete(id :: any(), user :: user()) :: query_result()

    @optional_callbacks new: 2,
                        get: 2,
                        get_count: 2,
                        show: 2,
                        update: 2,
                        edit: 3,
                        delete: 2

    defmacro __using__(opts \\ []) do
      quote do
        name = unquote(Utils.name_or_option(__CALLER__.module, opts[:name]))

        use Ecto.Schema

        import Ecto.Query

        alias unquote(
                opts[:repo] || Utils.slice_replace(__CALLER__.module, "Repo")
              )

        alias Ecto.Changeset

        @behaviour Warlock.Schema

        @private_fields Keyword.get(unquote(opts), :private_fields, [])
        @required_fields Keyword.get(unquote(opts), :required_fields, [])
        @writable_fields Keyword.get(unquote(opts), :writable_fields, [])
        @user_field Keyword.get(unquote(opts), :user_field, "user")

        key_type = Application.get_env(name, :primary_key_type, :binary_id)
        @foreign_key_type key_type
        @primary_key {:id, key_type, autogenerate: true}

        @items_per_page Application.get_env(name, :items_per_page, 20)

        def private_fields(), do: @private_fields

        def filter_by_params(query, _params), do: query

        def filter_by_admin(query), do: query
        def filter_by_user(query, user), do: query
        def filter_by_anyone(query), do: query

        @doc """
        Applies filters for the given user. At this point the model has already
        checked permissions, so it's just about applying them in the query.
        """
        def apply_user(query, user) do
          cond do
            user == :admin ->
              unquote(__CALLER__.module).filter_by_admin(query)

            user == :anyone ->
              unquote(__CALLER__.module).filter_by_anyone(query)

            true ->
              unquote(__CALLER__.module).filter_by_user(query, user)
          end
        end

        def set_user(params, user) do
          cond do
            user == :admin -> params
            user == :anyone -> params
            true -> Map.put(params, @user_field, user)
          end
        end

        def order_items(query, _params), do: order_by(query, desc: :id)

        def limit_items(query, %{"items" => items}), do: limit(query, ^items)

        def limit_items(query, _params), do: limit(query, @items_per_page)

        def page(page, items) do
          (String.to_integer(page) - 1) * String.to_integer(items)
        end

        def apply_offset(query, %{"page" => page, "items" => items}) do
          offset(query, ^page(page, items))
        end

        def apply_offset(query, %{"page" => page}) do
          offset(query, ^page(page, @items_per_page))
        end

        def apply_offset(query, _params), do: query

        def handle_query(query) do
          try do
            query
          rescue
            e in Ecto.Query.CastError -> {:error, e}
            e in Ecto.QueryError -> {:error, e}
          end
        end

        def fetch_items(query, params) do
          query
          |> group_by(:id)
          |> order_items(params)
          |> limit_items(params)
          |> apply_offset(params)
          |> Repo.all()
        end

        def count_items(query) do
          query
          |> group_by(:id)
          |> subquery([:q])
          |> select([q], count(q.id))
          |> Repo.all()
          |> List.first()
        end

        def changeset(struct, params) do
          struct
          |> Ecto.Changeset.cast(params, @writable_fields)
          |> Ecto.Changeset.validate_required(@required_fields)
        end

        @impl true
        def new(params, user) do
          params = unquote(__CALLER__.module).set_user(params, user)

          __struct__()
          |> unquote(__CALLER__.module).changeset(params)
          |> Repo.insert()
        end

        @impl true
        def get(params, user) do
          unquote(__CALLER__.module)
          |> unquote(__CALLER__.module).apply_user(user)
          |> unquote(__CALLER__.module).filter_by_params(params)
          |> unquote(__CALLER__.module).fetch_items(params)
        end

        @impl true
        def get_count(params, user) do
          unquote(__CALLER__.module)
          |> unquote(__CALLER__.module).apply_user(user)
          |> unquote(__CALLER__.module).filter_by_params(params)
          |> unquote(__CALLER__.module).count_items()
        end

        @impl true
        def show(id, user) do
          unquote(__CALLER__.module)
          |> where(id: ^id)
          |> unquote(__CALLER__.module).apply_user(user)
          |> unquote(__CALLER__.module).fetch_items(%{"items" => 1})
        end

        @impl true
        def update(item, params) do
          item
          |> unquote(__CALLER__.module).changeset(params)
          |> Repo.update()
        end

        @impl true
        def edit(params, id, user) do
          case unquote(__CALLER__.module).show(id, user) do
            [] -> :not_found
            [item] -> unquote(__CALLER__.module).update(item, params)
          end
        end

        @impl true
        def delete(id, user) do
          unquote(__CALLER__.module)
          |> where(id: ^id)
          |> apply_user(user)
          |> Repo.delete_all()
          |> unquote(__CALLER__.module).handle_query()
        end

        defoverridable changeset: 2,
                       filter_by_params: 2,
                       filter_by_user: 2,
                       order_items: 2,
                       limit_items: 2,
                       handle_query: 1,
                       fetch_items: 2,
                       count_items: 1,
                       page: 2,
                       apply_offset: 2,
                       new: 2,
                       get: 2,
                       get_count: 2,
                       show: 2,
                       update: 2,
                       edit: 3,
                       delete: 2
      end
    end
  end
else
  defmodule Warlock.Schema do
  end
end
