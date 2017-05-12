defmodule Firex do

  @moduledoc """
  Module with macro for generating `main` entrypoint and reflection of passed
  command line argument into functions.
  """

  defmacro __using__(_opts) do
    quote do
      import Firex

      @before_compile Firex
      @on_definition {Firex, :on_def}

      def main(args \\ []) do
        commands =  what_defined |> Enum.map(&opt_pair/1)
        commands_map = Enum.reduce(commands, %{}, fn (map, acc) -> Map.merge(acc, map) end)
        help_info = what_defined |>  Enum.map(fn {name, _, doc, tspec} -> {name, {doc, tspec}} end) |> Enum.into(%{})
        state = %{args: args, exausted: false, help_fn: fn -> help(commands_map, help_info) end}
        %{exausted: exausted} = Enum.reduce(commands, state, &traverse_commands/2)
        exausted
      end

      defp traverse_commands(pair, %{args: args, exausted: false, help_fn: help_fn} = state) do
        name = pair |> Map.keys() |> Enum.at(0)
        cmd = pair |> Map.values() |> Enum.at(0)
        parsed = OptionParser.parse(args, cmd)
        cmd_name = Atom.to_string(name)
        case parsed do
          {opts, [^cmd_name], _} ->
            fn_args = opts |> Enum.map(fn {k, v} -> v end)
            try do
              Kernel.apply(__MODULE__, name, fn_args)
              %{state | exausted: true}
            rescue
              UndefinedFunctionError ->
                help_fn.()
                state
            end
          {_, [_], _} ->
            state
        end

      end
      defp traverse_commands(_, %{exausted: true} = state) do
        state
      end

      defp help(cm, help_info) do
        msg = cm |> Enum.map(fn {name, params} ->
          signature = params
          |> Keyword.get(:aliases, [])
          |> Enum.map(fn {k, v} -> "-#{k} --#{v} <#{v}>"  end)
          |> Enum.join(", ")

          meta = Map.get(help_info, name, {nil, nil})
          {doc, _} = meta
          """
          #{name}: #{signature}

              #{doc}
          """
        end) |> Enum.join("\n")

        IO.puts """
        #{pub_moduledoc}
        Usage:

            <command>

        Available commands

          #{msg}
        """
      end
    end
  end

  defmacro __before_compile__(_) do
    quote do
      def what_defined do
        @commands
      end
      def pub_moduledoc do
        @pub_moduledoc
      end
    end
  end

  @lint false
  def on_def(_env, _kind, :dispatch, _args, _guards, _body) do
  end
  def on_def(_env, _kind, :main, _args, _guards, _body) do
  end
  def on_def(env, :def, name, args, _guards, _body) do
    module = env.module
    defs = Module.get_attribute(module, :commands) || []
    doc = case Module.get_attribute(module, :doc) do
      nil -> ""
      {_, doc} -> doc
    end
    fn_def = {name, args, doc, Module.get_attribute(module, :spec)}
    Module.put_attribute(module, :commands, [fn_def | defs])

    moduledoc = case Module.get_attribute(module, :moduledoc) do
      nil -> ""
      {_line, moduledoc} -> moduledoc
    end
    Module.put_attribute(module, :pub_moduledoc, moduledoc)
  end
  def on_def(_env, _kind, _name, _args, _guards, _body) do
  end

  def opt_pair({name, args, _, __}) do
    switches = args
    |> Enum.map(&Firex.arg_name/1)
    |> Enum.map(fn name -> {name, :string} end)
    |> Enum.into(Keyword.new)
    aliases = switches
    |> Enum.map(fn {k, _} -> {
      k
      |> Atom.to_string()
      |> String.at(0)
      |> String.to_atom(), k
      }
    end)
    |> Enum.into(Keyword.new)
    %{name => [switches: switches, aliases: aliases]}
  end
  def opt_pair(_) do
    %{}
  end

  def arg_name({:\\, _line, [{name, _, nil}, _default]}) do
    name
  end
  def arg_name({name, _line, _}) do
    name
  end

  def main(_args \\ []) do
  end
end
