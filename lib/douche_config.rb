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
  
  def config
    @config ||= normalize(YAML.load(File.read(config_path)))
  end

  def config_path
    return options[:config_file] if options[:config_file]
    raise "Cannot determine home directory when looking up configuration file path" unless ENV['HOME']
    File.join(ENV['HOME'], '.douche.yml')
  end
  
  def normalize(data)
    new_data = {}
    data.each_pair {|path, nozzles| new_data[path] = hashify(nozzles) }
    new_data
  end
  
  def nozzles
    paths = active_paths
    return [] if paths.empty?
    raise "Configuration file [#{config_path}] declares overlapping paths!" if paths.size > 1
    config[paths.first].keys
  end

  def active_paths
    config.keys.select {|path| active_path? path }
  end
  
  def active_path?(path)
    contains?(directory, path)
  end
  
  def contains?(container, containee)
    container_paths = File.expand_path(container).split(File::Separator)
    containee_paths = File.expand_path(containee).split(File::Separator)
    while !container_paths.empty?
      break unless container_paths.first == containee_paths.first
      container_paths.shift
      containee_paths.shift      
    end
    container_paths.empty?
  end
  
  private
  
  def hashify(thing)
    return thing if thing.respond_to? :keys
    thing.inject({}) do |h, key|
      h[key] = {}
      h
    end
  end
end
