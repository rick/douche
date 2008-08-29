require 'find'
require 'nozzle'

class Douche
  attr_reader :directory, :options
  
  def initialize(options)
    raise ArgumentError, ":directory is required" unless options[:directory]
    @directory = options[:directory]
    @options = options
  end
  
  def douche
    Find.find(directory) { |path| douche_file(path) if File.file? path }
  end
  
  def douche_file(file)
    nozzles.each {|klass| klass.new(options).douche(file) }
  end
  
  def nozzles
    return @nozzles if @nozzles
    Find.find(nozzle_path) { |nozzle| require nozzle if File.file? nozzle }
    @nozzles = Nozzle.nozzles
  end
  
  def nozzle_path
    File.expand_path(File.dirname(__FILE__) + '/nozzles/')
  end
end
