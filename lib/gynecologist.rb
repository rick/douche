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
    save_douched_statuses(nozzle, statuses.merge(file => true))
  end
  
  def douched_statuses(nozzle)
    YAML.load(File.read(status_file(nozzle)))
  rescue
    { }
  end
  
  def save_douched_statuses(nozzle, statuses)
    file_create(status_file(nozzle), YAML.dump(statuses))
    true
  rescue
    false
  end
  
  def status_file(name)
    File.join(directory, ".douche_#{name}")
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
