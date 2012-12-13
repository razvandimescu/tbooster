class ReloadFileCommand < Command
  @@to_reload = {}
  def to_reload
    @@to_reload
  end

  def initialize(file)
    self.file = file
  end

  def run
    return if !ReloadFileCommand.is_reloadable_file(file)

    if to_reload[file] == nil
      reload
    else
      last_reload_time = Time.now - to_reload[file]
      if last_reload_time > 5 #more than 5 seconds passed since the last file reload
        reload
      end
    end
  end

  def reload
    #ActiveRecord::Base.establish_connection ENV['RAILS_ENV']
    to_reload[file] = Time.now
    puts "change detected for: #{file}"
    load file
  end

  def self.is_reloadable_file(file)
    return true if (file =~ watchable_file)
    return false
  end

  def self.watchable_file
    /((app\/(models|controllers|helpers))|lib)\/(.*)\.rb$/
  end
end

