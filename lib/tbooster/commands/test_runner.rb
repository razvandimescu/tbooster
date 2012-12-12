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
    
    test_start = Time.now

    fork do
      ActiveRecord::Base.establish_connection ENV['RAILS_ENV']

      puts "running: #{file}"
      ARGV.replace(args)
      require(file.gsub(".rb", ""))

      test_end = Time.now
    end
  end

  def is_test_file
    file =~ /test\/(.*)\/(.*)_test\.rb$/
  end
end
