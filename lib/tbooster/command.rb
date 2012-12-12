class Command
  attr_accessor :file, :args

  def self.get(arg)
    args = arg.gsub("\n","").split(' ')

    if args.length < 2
      return InvalidCommand.new
    end

    cmd = args[0]
    file = args[1]

    case cmd
      when 'reload_file'
        return ReloadFileCommand.new(file)
      when 'run'
        return TestRunnerCommand.new(file, args[1..-1] || [])
    end


    return Command.new
  end

  def run
    puts "unknown command"
  end

end

