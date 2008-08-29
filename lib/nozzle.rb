class Nozzle
  attr_reader :options
  
  def self.nozzles
    subclasses = []
    ObjectSpace.each_object(Class) do |klass|
      subclasses << klass if klass < Nozzle
    end
    subclasses
  end
  
  def initialize(options)
    @options = options
    @dry_run = options[:dry_run]
  end
  
  def dry_run?
    !! @dry_run
  end
  
  def douche(file)
    spray file if !dry_run? and stank? file
  end
  
  def stank?(file)
    false
  end
end
