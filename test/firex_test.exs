defmodule Firex.Simple do
  use Firex
  @moduledoc """
  This a sample of cmd app module where we only define function with signatures
  """
  @spec launch(String.t, String.t, Bool.t) :: String.t
  def launch(message, path, _force \\ false) when is_binary(message) do
    IO.puts "Hallo #{message} at `#{path}`"
  end

  @spec stop(String.t) :: String.t
  def stop(task) when is_binary(task) do
    IO.puts "Task here #{task}"
  end

end


defmodule Firex.MatchSample do
  use Firex
  @moduledoc """
  Ensure pattern matching
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


defmodule FirexTest do
  use ExUnit.Case
  doctest Firex
  @moduledoc """
  Tests for dsl
  """

  test "macro should collect function definition" do
    refute Firex.Simple.what_defined == nil
    refute Firex.Simple.what_defined == []
  end

  test "it should accept raw params" do
    assert Firex.Simple.main(["launch", "-m", "hallo", "--path", ".", "-w", "1"])
  end

  test "it should be to call any function from exposed module" do
    assert Firex.Simple.main(["stop", "-t", "Omg"])
  end

  test "it should match to passed params to avaiable definitions" do
    assert Firex.MatchSample.main(["launch", "-m", "hallo", "--path", "pwd", "-f", "1"])
    assert Firex.MatchSample.main(["launch", "-m", "hallo", "--path", "pwd"])
  end
end
