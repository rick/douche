require 'gynecologist'

class Nozzle
  attr_reader :options, :directory, :config
  
  def self.nozzles
    subclasses = []
    ObjectSpace.each_object(Class) do |klass|
      subclasses << klass if klass < Nozzle
    end
    subclasses
  end
  
  def initialize(config)
    @config = config
    @options = config.options
    @dry_run = options[:dry_run]
    @verbose = options[:verbose]
    @directory = options[:directory]
  end

  # to be overridden by descendant Nozzles
  def stank?(file)
    false
  end
  
  # to be overridden by descendant Nozzles
  def spray(file)
  end

  def params
    @params ||= config.nozzle_parameters(name)
  end
  
  def name
    File.basename(filename).sub(%r{^(.*)_nozzle\.rb$}, '\1')
  end
  
  def dry_run?
    !! @dry_run
  end
  
  def verbose?
    !! @verbose
  end
  
  def douche(file)
    return unless stank? file
    puts "Nozzle [#{self.class.name}] Processing file [#{file}]..." if verbose?
    spray file
  end
  
  def douched?(file)
    status.douched?(name, file)
  end

  def status
    @status ||= Gynecologist.new(options)
  end

  def douched
  end

  def relative_path
  end

  def copy
  end
  
  private
  
  # this is only here to facilitate testing, as Ruby otherwise gives no way to control the value of __FILE__.
  def filename
    __FILE__
  end
end
