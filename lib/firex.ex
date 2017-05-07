defmodule Firex do

    defmacro __using__(_opts) do
      quote do
        import Firex

        @before_compile Firex
        @on_definition {Firex, :on_def}
      end

    end

    defmacro __before_compile__(_) do
        quote do
            def what_defined do
                @commands
            end
        end
    end

    def on_def(env, _kind, name, args, guards, _body) do
      module = env.module
      defs = Module.get_attribute(module, :commands)
      Module.put_attribute(module, :commands, [{name, args, guards} | defs])
      # :ok = Agent.update(@agent, fn defs -> [{name, args, guards} | defs] end)
      # IO.inspect  Firex.Main.definitions
      # IO.puts "Defining #{kind} named #{name} with args:"
      # IO.inspect args
      # IO.puts "and guards"
      # IO.inspect guards
      # IO.puts "and body"
      # IO.puts Macro.to_string(body)
    end

end


defmodule Firex.Cli do
    use Firex

    @spec main(String.t, Bool.t) :: String.t
    def main(message, force \\ false) when is_binary(message) do
        IO.puts "Hallo #{message} and #{force}"
    end

end
