class TestRunnerCommand < Command
 def initialize(file, args)
    self.file = file
    self.args = args
  end
  
  def run
    if !is_test_file
      puts "this is not a test file"
      return
    end
    
    fork do
      ActiveRecord::Base.establish_connection ENV['RAILS_ENV']

      ARGV.replace(args)
      file_to_run = file.gsub(".rb", "").gsub("#{Dir.pwd}", "")
      require "#{Dir.pwd}/#{file_to_run}"
    end
  end

  def is_test_file
    file =~ /test\/(.*)\/(.*)_test\.rb$/
  end
end
