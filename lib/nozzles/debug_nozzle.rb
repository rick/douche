class DebugNozzle < Nozzle
  def stank?(file)
    true
  end

  def spray(file)
    STDERR.puts "parameters [#{params.inspect}]"
    STDERR.puts ":::::: #{file}"
  end

  private
  
  def filename
    __FILE__
  end
end
