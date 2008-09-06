require 'find'
require 'nozzle'
require 'douche_config'

class Douchebag
  attr_reader :directory, :options, :config
  
  def initialize(options)
    raise ArgumentError, ":directory is required" unless options[:directory]
    @directory = options[:directory]
    @verbose = options[:verbose]
    @options = options
  end
  
  def verbose?
    !! @verbose
  end
  
  def nozzles
    return @nozzles if @nozzles
    Find.find(nozzle_path) { |nozzle| require nozzle if applicable?(nozzle) }
    @nozzles = Nozzle.nozzles
  end
  
  def nozzle_path
    File.expand_path(File.dirname(__FILE__) + '/nozzles/')
  end

  def applicable?(nozzle_path)
    return false unless name = nozzle_name(nozzle_path)
    active?(name)
  end

  def nozzle_name(path)
    return false unless path =~ /_nozzle\.rb$/
    path.sub(%r{^(.*/)?([^/]+)_nozzle\.rb$}, '\2')
  end
  
  def active?(name)
    # config. (something about the .directory somehow enclosing or overlapping one of the paths in the nozzle's path list)
  end
  
  def config
    @config ||= DoucheConfig.new(options)
  end
end
