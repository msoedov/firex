defmodule Firex.Main do
  @agent __MODULE__

  def start_link do
    {:ok, _pid} = Agent.start_link(fn -> [] end, name: @agent)
  end

  def definitions do
    IO.puts @agent
    Agent.get(@agent, fn state -> state end)
  end

  def on_def(_env, _kind, name, args, guards, _body) do
    :ok = Agent.update(@agent, fn defs -> [{name, args, guards} | defs] end)
    IO.inspect  Firex.Main.definitions
    # IO.puts "Defining #{kind} named #{name} with args:"
    # IO.inspect args
    # IO.puts "and guards"
    # IO.inspect guards
    # IO.puts "and body"
    # IO.puts Macro.to_string(body)
  end
end


defmodule Firex do

    defmacro __using__(_opts) do
      quote do
        import Firex
        Firex.Main.start_link

        @on_definition {Firex.Main, :on_def}

        def what_defined do
            Firex.Main.definitions
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
