require 'find'
require 'yaml'
require 'nozzle'

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
    # TODO:  This should probably be in the Nozzle class
    Find.find(nozzle_path) { |nozzle| require nozzle if applicable_nozzle?(nozzle) }
    @nozzles = Nozzle.nozzles
  end
  
  def nozzle_path
    File.expand_path(File.dirname(__FILE__) + '/nozzles/')
  end

  def applicable?(nozzle_path)
    @config = load_configuration unless config
    return false unless name = nozzle_name(nozzle_path)
    active?(name)
  end

  def nozzle_name(path)
    return false unless path =~ /_nozzle\.rb$/
    path.sub(%r{^(.*/)?([^/]+)_nozzle\.rb$}, '\2')
  end
  
  def active?(name)
    # TODO:
  end

  # TODO:  this should probably be moved out to a configuration class
  def load_configuration
    YAML.load(File.read(config_path))
  end
  
  # TODO: this should probably be moved out to a configuration class
  def config_path
    raise "Cannot determine home directory when looking up configuration file path" unless ENV['HOME']
    File.join(ENV['HOME'], '.douche.yml')
  end
end
