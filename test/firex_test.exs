defmodule Firex.Simple do
  use Firex, testing: true

  @moduledoc """
  This a sample of cmd app module where we only define function with signatures
  """

  @doc """
  Launch some thing
  """
  @spec launch(String.t, String.t, Bool.t) :: String.t
  def launch(message, path, _force \\ false) when is_binary(message) do
    IO.puts "Hallo #{message} at `#{path}`"
  end

  @spec stop(String.t) :: String.t
  def stop(task) when is_binary(task) do
    IO.puts "Task here #{task}"
  end

  @spec should_takes_bool(Bool.t) :: String.t
  def should_takes_bool(flag) do
    IO.puts "Flag #{flag}"
  end

  @spec should_takes_int(Integer.t) :: String.t
  def should_takes_int(num) do
    IO.puts "Flag #{num + 1}"
  end

  def can_have_no_spec(flag) do
    IO.puts "Flag #{flag}"
  end

  @spec error() :: String.t
  def error do
    raise("Error here")
  end

end


defmodule Firex.MatchSample do
  use Firex, testing: true
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

  test "it should accept unnamed params" do
    assert Firex.Simple.main(["launch", "hallo", "."])
  end

  test "it should handle errors" do
    assert_raise RuntimeError, fn -> Firex.Simple.main(["error"]) end
  end

  test "it should reject empty params" do
    refute Firex.Simple.main([])
  end

  test "it reject invalid params" do
    refute Firex.Simple.main(["launch", "--what", "broken"])
    refute Firex.MatchSample.main(["launch", "--what", "broken"])
  end

  test "it should be to call any function from exposed module" do
    assert Firex.Simple.main(["stop", "-t", "Omg"])
  end

  test "it should match to passed params to avaiable definitions" do
    assert Firex.MatchSample.main(["launch", "-m", "hallo", "--path", "pwd", "-f"])
    assert Firex.MatchSample.main(["launch", "-m", "hallo", "--path", "pwd"])
  end

  test "it should convert bool flag" do
    assert Firex.Simple.main(["should_takes_bool", "-f", "1"])
  end

  test "it should grasefully handle extra arguments" do
    assert Firex.Simple.main(["should_takes_bool", "-f", "1", "2"])
  end

  test "it should convert int arg" do
    assert Firex.Simple.main(["should_takes_int", "-n", "1"])
    refute Firex.Simple.main(["should_takes_int", "-n", "1n"])
    # fixme:
    assert_raise ArithmeticError, fn -> Firex.Simple.main(["should_takes_int", "1"]) end
  end

  test "it should work without spec" do
    assert Firex.Simple.main(["can_have_no_spec", "-f", "1"])
    refute Firex.Simple.main(["can_have_no_spec"])
  end

  test "it should reply on help" do
    refute Firex.Simple.main(["-h"])
    refute Firex.Simple.main(["--help"])
    refute Firex.Simple.main(["help"])
  end
end
