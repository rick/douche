require 'ftools'

class Gynecologist
  attr_reader :options, :directory
  
  def initialize(options)
    @options = options
    @directory = options[:directory]
  end
  
  def douched?(nozzle, file)
    douched_statuses(nozzle).has_key?(file)
  end
  
  def douched(nozzle, file)
    statuses = douched_statuses(nozzle)
    statuses[file] = true
    update_douched_statuses(nozzle, file)
  end
  
  def douched_statuses(nozzle)
    return @douched_statuses if @douched_statuses
    @douched_statuses =
      begin
        YAML.load(File.read(status_file(nozzle))) || {}
      rescue
        { }
      end
  end
  
  def update_douched_statuses(nozzle, douched_file)
    file = status_file(nozzle)
    if File.file?(file)
      File.open(file, 'a+') do |f|
        f.puts "#{douched_file}: true"
      end      
    else
      file_create(file, YAML.dump(@douched_statuses))
    end
    true
  rescue
    false
  end
  
  def status_file(name)
    status_path = options[:status_path] ? options[:status_path] : File.join(ENV['HOME'], '.douche')
    File.makedirs(status_path) unless File.directory?(status_path)
    File.join(status_path, ".douche_#{name}")
  end
  
  def enclosing_directory(file)
    File.expand_path(File.dirname(file))
  end
  
  private
  
  # stolen shamelessly from Ruby Facets ... why is this not in stdlib?  bitches.
  def file_create(path, str='', &blk)
    File.open(path, 'wb') do |f|
      f << str
      blk.call(f) if blk
    end
  end
end
