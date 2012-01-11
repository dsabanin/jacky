module Jacky
  class GenericScope
    def initialize(scope, argv)
      @scope = scope
      @argv = argv
      if @argv
        if @scope == :generic
          die_with_msg "unknown scope"
        end
        trigger_command(@argv.first)
      else
        on_help
      end
    end

    def trigger_command(command)
      meth = "on_#{command}"
      if respond_to?(meth)
        send(meth)
      else
        die_with_msg("unknown command #{command}")
      end
    end

    def on_help
      output "Usage: #{$0} scope command\n\n"
      output "Available scopes are: repository, account"
      output "To view available commands try scope name and \"help\" command:"
      output "  #{$0} repository help"
      output "\n(c) Dima Sabanin, 2012. http://sabanin.ru"
    end

    def die!
      exit 1
    end

    def die_with_msg(msg)
      output "Error: #{msg}\n\n"
      on_help
      die!
    end

    def output(msg)
      STDERR.puts(msg)
    end

    def parse_boolean(obj)
      obj.to_s.downcase == "true" or obj.to_s.to_i == 1 or obj.to_s.downcase == "t"
    end
  end
end
