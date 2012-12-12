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
    return true if (file =~ /app\/(models|controllers|helpers)\/(.*)\.rb$/)
    return true if (file =~ /lib\/(.*)\.rb$/)

    #views must be watched too :(
    #return file =~ /app\/views\/(.*)(\.rhtml|\.html.erb|\.rjs)$/
    return false
  end
end

