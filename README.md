# Warlock

![GitHub Workflow Status](https://img.shields.io/github/workflow/status/strangemachines/warlock/test?style=for-the-badge)
[![Hexdocs](https://img.shields.io/badge/docs-hexdocs-blueviolet.svg?style=for-the-badge)](https://hexdocs.pm/warlock)
[![Hex.pm](https://img.shields.io/hexpm/v/warlock.svg?style=for-the-badge)](https://hex.pm/packages/warlock)

Warlock is an API building library that generates as much code as possible, without getting in the way.

## Installation

```elixir
{:warlock, "~> 0.3"}
```

## Usage

### Application

Creating an application with Ecto and Plug in the supervision tree:

```elixir
defmodule MyApp.Application do
  use Warlock.Application, repo: true
end
```

Don't forget the obligatory `mod: {MyApp.Application, []}` in your mix.exs!

### Handler

An handler calls a controller and transforms the result into an http
response. A view basically.

```elixir
defmodule MyApp.Handlers.Flowers do
  use Warlock.Handler
end
```

Warlock expects an optional get/1 function in handlers. In this example, MyApp.Controllers.Flowers.get/2 gets called and the result is transformed
into an http response.  

```elixir
@impl true
def get(conn) do
  case Flowers.get(nil, conn) do
    {:ok, items} -> send_200(conn, items)
    {:error, error} -> send_400(conn, error)
  end
end
```


Warlock comes with first-class Siren support, and that's one of the best part
because it's where I put more effort. All you have do to have a properly
structured Siren response, besides routing the request to get/1, is:

```elixir
defmodule MyApp.Handlers.Flowers do
  use Warlock.Handler, response_type: :siren

  @impl true
  def get(conn) do
    case Flowers.get(nil, conn) do
      {:ok, items} -> send_200(conn, items, Enum.count(items))
      {:error, error} -> send_400(conn, error)
    end
  end
end
```

### Controllers

Not much happens in controllers in Warlock...for now.

### Models

Models are the place for permissions and other shared behaviours.

### Schemas

Use Warlock.Schema to get some callbacks and imports done for you.
