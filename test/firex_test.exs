defmodule FirexTest do
  use ExUnit.Case
  doctest Firex

  test "the truth" do
    IO.inspect Firex.Cli.what_defined
    # IO.inspect unquote Macro.escape(Firex)
    assert 1 + 1 == 2
  end
end
