class Command
  attr_accessor :file, :args

  def self.get(arg)
    args = arg.gsub("\n","").split(' ')

    if args.length < 2
      return InvalidCommand.new
    end

    if(args[0] == 'reload' || args[0] == "run")
      test_args = args[1].split(' ')

      cmd = args[0]
      file = test_args[0]
      args = test_args[1..-1] || []

      case cmd
        when 'reload'
          return ReloadFileCommand.new(file)
        when 'run'
          return TestRunnerCommand.new(file, test_args)
      end
    end

    return Command.new
  end

  def run
    puts "unknown command"
  end

end

