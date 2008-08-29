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
  end
  
  def douche(file)
    spray file if stank? file
  end
  
  def stank?(file)
    false
  end
end
