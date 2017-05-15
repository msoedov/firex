# Firex

[![Build Status](https://travis-ci.org/msoedov/firex.svg?branch=master)](https://travis-ci.org/msoedov/firex)
[![Hex Version](https://img.shields.io/hexpm/v/firex.svg)](https://hex.pm/packages/firex)

Firex is a library for automatically generating command line interfaces (CLIs) from an elixir module

- Inspired by [Python Fire](https://github.com/google/python-fire)
- Built on top of `OptionParser` and `escript`
- Enhance exploring existing code or turning other people's code into a CLI for evaluation.
- Outputs [escript]( http://erlang.org/doc/man/escript.html) script executable (binary data)


## Basic Usage

Add `use Firex` to any module you would like to expose

```elixir
defmodule Example do
  use Firex
  @moduledoc """
  Module for my awesome launcher
  """

  @doc """
  Launch some awesome thing
  """
  @spec launch(String.t, String.t) :: String.t
  def launch(message, path) do
    IO.puts "Hallo #{message} at `#{path}`"
  end
  @spec launch(String.t, String.t, Bool.t) :: String.t
  def launch(message, path, force) when is_binary(message) do
    IO.puts "Hallo #{message} at `#{path}` and forced #{force}"
  end

  @doc """
  Stop previous task by id
  """
  @spec stop(String.t) :: String.t
  def stop(task_id) do
    IO.puts "Stopping task #{task_id}"
  end

end
```

Add it `escript: [main_module: Example]` to your mix file
```elixir
# mix.exs
def project do
  [
   ...
    escript: [main_module: Example],
   ...
  ]
end
```
and then

```shell
➜ mix escript.build
Generated escript app with MIX_ENV=dev
➜ ./app
Module for my awesome launcher

Usage:

    <command>

Available commands:

    launch: -m --message <message>, -p --path <path>, -f --force <force>

        Launch some awesome thing


    stop: -t --task_id <task_id>

        Stop previous task by id
```

## Installation

If [available in Hex](https://hex.pm/packages/firex), the package can be installed as:

Add `firex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:firex, "~> 0.1.0"}]
end
```

## Todos

Known issues and opportunity for improvements:

- [ ] Convert `@spec` into `OptionParser` flags
  - Currently only `:string` is used
- [ ] Proper exit codes
  - Proper exit code on traceback
- [ ] Warn when extra arguments passed
- [ ] Autoregister main module - e.g `escript: [main_module: Example]``
- [ ] Colour output

## License

Firex is [MIT Licensed](./LICENSE).
