defmodule Firex.Main do
  @names []

  def on_def(_env, kind, name, args, guards, body) do
    # @names [name|@names]

    IO.puts "Defining #{kind} named #{name} with args:"
    IO.inspect args
    IO.puts "and guards"
    IO.inspect guards
    IO.puts "and body"
    IO.puts Macro.to_string(body)
  end
end


defmodule Firex do

    defmacro __using__(_opts) do
      quote do
        import Firex
        @on_definition {Firex.Main, :on_def}

        def what_defined do
        end

      end
    end

end


defmodule Firex.Cli do
    use Firex

    @spec main(String.t, Bool.t) :: String.t
    def main(message, force \\ false) when is_binary(message) do
        IO.puts "Hallo #{message} and #{force}"
    end

end
