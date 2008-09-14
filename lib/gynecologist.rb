 class Gynecologist
   attr_reader :options, :directory
   
   def initialize(options)
     @options = options
     @directory = options[:directory]
   end
   
   def douched?(nozzle, file)
     douched_statuses(nozzle).has_key?(file)
   end

   def douched_statuses(nozzle)
     YAML.load(File.read(status_file(nozzle)))
   rescue
     { }
   end

   def status_file(name)
     File.join(directory, ".douche_#{name}")
   end
   
   def enclosing_directory(file)
     File.expand_path(File.dirname(file))
   end
end
