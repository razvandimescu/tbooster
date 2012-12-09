class Tbooster
  def self.pid
    "tmp/tbooster.pid"
  end

  def self.pipe
    "tmp/tbooster_pipe"
  end

  def self.listeners_loaded?
    if File.exists?(pid)
      return true
    end
    return false
  end

  def self.start_listeners
    command_listener
    file_listener
  end

  def self.command_listener
    fork do
      File.open(pid, "a") { |f| f<<" #{Process.pid}" }

      input = open(pipe, "r+")
      while true do
        cmd = Command.get(input.gets) #read is blocked until new content is added on the pipe

        begin
          cmd.run
        rescue Exception => e
          puts "Message: #{e.message}"
          puts "Stack: #{e.backtrace}"
        end
      end
    end
  end

  def self.file_listener
    fork do
      File.open(pid, "a") { |f| f<<" #{Process.pid}" }

      require 'rb-inotify'

      output = open(pipe, "w+")

      notifier = INotify::Notifier.new

      notifier.watch("./", :modify, :recursive) do |event|
        output.puts "reload:#{event.absolute_name}"
        output.flush
      end

      notifier.run
    end
  end

  def self.send(args)
    unless File.exist?(pipe)
      %x( mkfifo #{pipe} )
    end

    if args.length > 0
      output = open(pipe, "w+") # the w+ means we don't block
      output.puts args.join(" ")
      output.flush
    end
  end
end

require 'tbooster/command'
require 'tbooster/commands/reload'
require 'tbooster/commands/test_runner'

