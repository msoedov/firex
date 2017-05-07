defmodule FirexTest do
  use ExUnit.Case
  doctest Firex

  test "Macro should work" do
    refute Firex.Cli.what_defined == nil
    refute Firex.Cli.what_defined == []
  end

  test "dispatch" do
    assert Firex.Cli.dispatch(["main", "-m", "hallo", "--path", ".", "-w", "1"])
  end
end
