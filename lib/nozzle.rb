class Nozzle
  attr_reader :options, :directory
  
  def self.nozzles
    subclasses = []
    ObjectSpace.each_object(Class) do |klass|
      subclasses << klass if klass < Nozzle
    end
    subclasses
  end
  
  def initialize(options)
    @options = options
    @dry_run = options[:dry_run]
    @verbose = options[:verbose]
    @directory = options[:directory]
  end
  
  def dry_run?
    !! @dry_run
  end
  
  def verbose?
    !! @verbose
  end
  
  def douche(file)
    puts "Nozzle [#{self.class.name}] Processing file [#{file}]..." if verbose?
    spray file if stank? file
  end
  
  # to be overridden by descendant Nozzles
  def stank?(file)
    false
  end
  
  # to be overridden by descendant Nozzles
  def spray(file)
  end
end
