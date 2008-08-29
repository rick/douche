class Nozzle
  def self.nozzles
    subclasses = []
    ObjectSpace.each_object(Class) do |klass|
      subclasses << klass if klass < Nozzle
    end
    subclasses
  end
end
