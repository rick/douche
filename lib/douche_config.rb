require 'yaml'

class DoucheConfig
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
  
  def nozzle_is_active?(name)
  end

  def config
    @config ||= YAML.load(File.read(config_path))
  end
  
  def config_path
    return options[:config_file] if options[:config_file]
    raise "Cannot determine home directory when looking up configuration file path" unless ENV['HOME']
    File.join(ENV['HOME'], '.douche.yml')
  end
end
