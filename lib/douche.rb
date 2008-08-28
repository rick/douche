class Douche
  attr_reader :directory
  
  def initialize(options)
    raise ArgumentError, ":directory is required" unless options[:directory]
    @directory = options[:directory]
  end
end
