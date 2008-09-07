require 'douchebag'
require 'find'

class Douche
  attr_reader :directory, :options
  
  def initialize(options)
    raise ArgumentError, ":directory is required" unless options[:directory]
    @directory = options[:directory]
    @verbose = options[:verbose]
    @options = options
  end
  
  def verbose?
    !! @verbose
  end
  
  def douche
    Find.find(directory) { |path| douche_file(path) if File.file? path }
  end
  
  def douche_file(file)
    nozzles.each do |klass|
      puts "Douching file [#{file}] with nozzle [#{klass.name}]..." if verbose?
      klass.new(config).douche(file) 
    end
  end
  
  def nozzles
    @nozzles ||= douchebag.nozzles
  end
  
  def config
    douchebag.config
  end
  
  def douchebag
    @douchebag ||= Douchebag.new(options)
  end
end
