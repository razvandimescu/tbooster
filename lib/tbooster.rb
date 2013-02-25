class Tbooster
  #poor mans man check to verify if we're in a rails root
  def self.runned_from_rails_root?
    File.directory?("./app/views") && File.directory?("./app/models") && File.directory?("./app/controllers")
  end

  def self.pid
    "#{File.expand_path(Dir.pwd)}/tmp/tbooster.pid"
  end

  def self.pipe
    "#{File.expand_path(Dir.pwd)}/tmp/tbooster_pipe"
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

  def self.close_all_and_cleanup
    %x( rm -f #{pipe} ) if File.exists?(pipe)
    if File.exists?(pid)
      kill_opened_processes
      %x( rm -f #{pid} )
    end
  end

  def self.kill_opened_processes
    %x( kill -9 `cat #{pid}` ) 
  end

  def self.start_listeners
    puts "starting listeners"
    command_listener
    file_listener
  end

  def self.command_listener
    fork do
      puts 'starting testing environment'
      require "#{Dir.pwd}/test/test_helper"
      puts 'loaded testing environment'
      File.open(pid, "a") { |f| f<<" #{Process.pid}" }
      input = File.open(pipe, "r+")
      while true do
        cmd = Command.get(input.gets)

        begin
          cmd.run
        rescue Exception => e
          puts "Message: #{e.message}"
          puts "Stack: #{e.backtrace}"
        end
      end

      puts "closed command listener process"
    end
  end

  def self.file_listener
    fork do
      File.open(pid, "a") { |f| f<< " #{Process.pid}" }

      require 'rubygems'
      require 'listen'
      output = open(pipe, "w+")

      Listen.to('./', :filter => ReloadFileCommand.watchable_file) do |modified, added, removed|
        output.puts "reload_file #{modified || added}"
        output.flush
      end

      puts "closed watcher"

    end
  end

  def self.send(args)
    unless File.exist?(pipe)
      %x( mkfifo #{pipe} )
    end

    if args.length > 0
      output = open(pipe, "w+")
      output.puts "run #{args.join(' ')}"
      output.flush
    end
  end

  def self.reload
    Tbooster.close_all_and_cleanup
    Tbooster.start_listeners
  end
end

require 'tbooster/command'
require 'tbooster/commands/invalid'
require 'tbooster/commands/reload_file'
require 'tbooster/commands/test_runner'

