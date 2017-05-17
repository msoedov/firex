defmodule Firex.Options do
  @moduledoc """
  Helper module for mapping @spec dsl into OptionParser params
  """

  @doc"""
  This functions converts @spec into OptionParser :switches argumets

  The following switches types arguments:
  :boolean - sets the value to true when given (see also the “Negation switches” section below)
  :count - counts the number of times the switch is given
  The following switches take one argument:

  :integer - parses the value as an integer
  :float - parses the value as a float
  :string - parses the value as a string
  """
  def to_op_types([{:spec, {:::, _, [{_name, _line, types}|_]}, _}|_aliases]) do
    translation = %{:String => :string, :Bool => :boolean, :Integer => :integer, :Float => :float}
    types
    |> Enum.map(fn {{:., _, [{:__aliases__, _, [type|_]}, :t]}, _, []} -> type end)
    |> Enum.map(fn atom -> Map.get(translation, atom, :string) end)
  end
  def to_op_types(_) do
    []
  end

  @doc"""
  """
  def params_for_option_parser({name, args, _, spec}) do
    guessed_switches = args
    |> Enum.map(&argument_name/1)
    |> Enum.map(fn name -> {name, :string} end)
    |> Enum.into(Keyword.new)

    spec_switches = Firex.Options.to_op_types(spec)
    switches = guessed_switches
    |> Enum.zip(spec_switches)
    |> Enum.map(fn {{name, _}, sw} -> {name, sw} end)
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
  def params_for_option_parser(_) do
    %{}
  end

  def argument_name({:\\, _line, [{name, _, nil}, _default]}) do
    name
  end
  def argument_name({name, _line, _}) do
    name
  end
end
