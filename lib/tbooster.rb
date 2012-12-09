class Tbooster
  #poor mans man check to verify if we're in a rails root
  def self.runned_from_rails_root?
    File.directory?("./app/views") && File.directory?("./app/models") && File.directory?("./app/controllers")
  end

  def self.pid
    "tmp/tbooster.pid"
  end

  def self.pipe
    "tmp/tbooster_pipe"
  end

  def self.listeners_loaded?
    if File.exists?(pid) && listener_processes_exist?
      return true
    end
    return false
  end

  def self.listener_processes_exist?
    listener_pids = (%x( cat #{pid} ) || "").split(" ").map{|pid| pid.to_i}.select{|pid| pid > 0}
    return false if listener_pids.length != 2

    processes_exist = true

    listener_pids.each do |pid|
      begin
        Process.kill 0, pid
      rescue Exception => e
        return false
      end
    end
    
    processes_exist
  end

  def self.kill_zombies_and_cleanup
      %x( rm -f #{pipe} )
      %x( kill -9 `cat #{pid}` )
      %x( rm -f #{pid} )
  end

  def self.start_listeners
    puts "starting listeners"
    command_listener
    file_listener
  end

  def self.command_listener
    fork do
      puts 'starting testing environment'
      require 'test/test_helper'
      puts 'loaded testing environment'
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
      File.open(pid, "a") { |f| f<< " #{Process.pid}" }

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
require 'tbooster/commands/invalid'
require 'tbooster/commands/reload'
require 'tbooster/commands/test_runner'

