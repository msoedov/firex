defmodule FirexTest do
  use ExUnit.Case
  doctest Firex

  test "the truth" do
    IO.inspect Firex.Cli.what_defined
    refute Firex.Cli.what_defined == nil
    refute Firex.Cli.what_defined == []
  end
end
