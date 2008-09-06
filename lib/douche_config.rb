require 'yaml'

class DoucheConfig
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

  def load_configuration
    @config ||= YAML.load(File.read(config_path))
  end
  
  def config_path
    raise "Cannot determine home directory when looking up configuration file path" unless ENV['HOME']
    File.join(ENV['HOME'], '.douche.yml')
  end
end
