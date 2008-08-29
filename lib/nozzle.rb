class Nozzle
  def self.nozzles
    subclasses = []
    ObjectSpace.each_object(Class) do |klass|
      subclasses << klass if klass < Nozzle
    end
    subclasses
  end
  
  def douche(file)
    spray file if dirty? file
  end
end
