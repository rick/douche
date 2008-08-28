class Douche
  attr_reader :directory
  
  def initialize(options)
    raise ArgumentError, ":directory is required" unless options[:directory]
    @directory = options[:directory]
    @dry_run = options[:dry_run]
  end
  
  def dry_run?
    !! @dry_run
  end
  
  def douche
    douche_path(directory)
  end
  
  def douche_path(path)
    
  end
end
