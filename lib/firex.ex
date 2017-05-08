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
        {_, matched} = Enum.reduce(commands, {args, false}, &traverse_commands/2)
        matched
      end

      defp traverse_commands(pair, {args, false}) do
        name = Map.keys(pair) |> Enum.at(0)
        cmd = Map.values(pair) |> Enum.at(0)
        parsed = OptionParser.parse(args, cmd)
        cmd_name = Atom.to_string(name)
        case parsed do
          {opts, [^cmd_name], _} ->
            fn_args = opts |> Enum.map(fn {k, v} -> v end)
            Kernel.apply(__MODULE__, name, fn_args)
            {args, true}
          {_, [_], _} ->
            {args, false}
        end

      end
      defp traverse_commands(_, {args, true}) do
        {args, true}
      end

      defp help do
        IO.puts """
        Help message here:
        """
      end
    end
  end

  defmacro __before_compile__(_) do
    quote do
      def what_defined do
        @commands
      end
    end
  end

  def on_def(_env, _kind, :dispatch, _args, _guards, _body) do
  end
  def on_def(_env, _kind, :main, _args, _guards, _body) do
  end
  def on_def(env, :def, name, args, guards, _body) do
    module = env.module
    defs = Module.get_attribute(module, :commands) || []
    Module.put_attribute(module, :commands, [{name, args, guards} | defs])
  end
  def on_def(_env, _kind, _name, _args, _guards, _body) do
  end

  def opt_pair({name, args, _guards}) do
    switches = args
    |> Enum.map(&Firex.arg_name/1)
    |> Enum.map(fn name -> {name, :string} end)
    |> Enum.into(Keyword.new)
    aliases = switches
    |> Enum.map(fn {k, _} -> {Atom.to_string(k)
    |> String.at(0)
    |> String.to_atom(), k} end)
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
