require 'find'

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
    Find.find(directory) { |path| douche_file(path) if File.file? path }
  end
  
  def douche_file(file)
    nozzles.each {|klass| klass.new.douche(file) }
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
