defmodule Firex do

    defmacro __using__(_opts) do
      quote do
        import Firex

        @before_compile Firex
        @on_definition {Firex, :on_def}

        def main(args) do
            params =  what_defined |> Enum.map(&Firex.opt_pair/1)
            parsed = OptionParser.parse(args, List.first(params))
            IO.inspect parsed
            case parsed do
            	{[verbose: true], [cmd], _} -> :do_verbose_thing
            	{_, [cmd], _} -> :do_thing
            	_ -> :help
            end
        end

      end
    end

    defmacro __before_compile__(_) do
        quote do
            def what_defined do
                @commands
            end
        end
    end

    def on_def(_env, _kind, :dispatch, _args, _guards, _body) do
    end
    def on_def(env, :def, name, args, guards, _body) do
      module = env.module
      defs = Module.get_attribute(module, :commands) || []
      Module.put_attribute(module, :commands, [{name, args, guards} | defs])
    end
    def on_def(_env, _kind, _name, _args, _guards, _body) do
    end

    def opt_pair({_name, args, _guards}) do
        switches = args
        |> Enum.map(&Firex.arg_name/1)
        |> Enum.map(fn name -> {name, :string} end)
        |> Enum.into(Keyword.new)
        aliases = switches
        |> Enum.map(fn {k, _} -> {Atom.to_string(k)
                                    |> String.at(0)
                                    |> String.to_atom(), k} end)
        |> Enum.into(Keyword.new)
        [switches: switches, aliases: aliases]
    end
    def opt_pair(_) do
      []
    end

    def arg_name({:\\, _line, [{name, _, nil}, _default]}) do
      name
    end
    def arg_name({name, _line, _}) do
      name
    end
end


defmodule Firex.Cli do
    use Firex

    @spec launch(String.t, Bool.t) :: String.t
    def launch(message, path, force \\ false) when is_binary(message) do
        IO.puts "Hallo #{message} and #{path}"
    end

end
