require 'ftools'

class Gynecologist
  attr_reader :options, :directory
  
  def initialize(options)
    @options = options
    @directory = options[:directory]
  end

  def douched?(nozzle, file)
    re = Regexp.new('^' + Regexp.escape(file) + '$')
    File.open(status_file(nozzle), 'r') do |f|
      f.each { |line| return true if re.match(line) } 
    end
    false
  rescue
    false
  end
  
  def douched(nozzle, douched_file)
    File.open(status_file(nozzle), 'a+') {|f| f.puts douched_file }
    true
  rescue
    false
  end
  
  def status_file(name)
    status_path = options[:status_path] ? options[:status_path] : File.join(ENV['HOME'], '.douche')
    File.makedirs(status_path) unless File.directory?(status_path)
    File.join(status_path, ".douche_#{name}")
  end
end
