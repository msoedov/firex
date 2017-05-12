defmodule Firex.Proto.Cli do
  use Firex
  @moduledoc """
  Module for my awesome launcher
  """
  @doc """
  Launch some awesome thing
  """
  @spec launch(String.t, String.t) :: String.t
  def launch(message, path) when is_binary(message) do
    IO.puts "Hallo #{message} at `#{path}`"
  end
  @spec launch(String.t, String.t, Bool.t) :: String.t
  def launch(message, path, force) when is_binary(message) do
    IO.puts "Hallo #{message} at `#{path}` and forced #{force}"
  end

end
