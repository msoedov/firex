defmodule Firex.Cli do
  use Firex
  @moduledoc """
  This a sample of cmd app module where we only define function with signatures
  """
  @spec launch(String.t, Bool.t) :: String.t
  def launch(message, path, force \\ false) when is_binary(message) do
    IO.puts "Hallo #{message} at `#{path}`"
  end

  @spec stop(String.t) :: String.t
  def stop(task) when is_binary(task) do
    IO.puts "Task here #{task}"
  end

end


defmodule FirexTest do
  use ExUnit.Case
  doctest Firex

  test "Macro should work" do
    refute Firex.Cli.what_defined == nil
    refute Firex.Cli.what_defined == []
  end

  test "Call launch" do
    assert Firex.Cli.main(["launch", "-m", "hallo", "--path", ".", "-w", "1"])
  end

  test "Call stop" do
    assert Firex.Cli.main(["stop", "-t", "Omg"])
  end
end
