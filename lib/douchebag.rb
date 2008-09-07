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
    all_nozzles = config.nozzles
    return [] if all_nozzles.empty?
    all_nozzles.each {|nozzle| require nozzle_file(nozzle) }
    @nozzles = Nozzle.nozzles
  end

  def nozzle_file(name)
    File.join(nozzle_path, "#{name}_nozzle.rb")
  end

  def nozzle_path
    File.expand_path(File.dirname(__FILE__) + '/nozzles/')
  end

  def config
    @config ||= DoucheConfig.new(options)
  end
end
