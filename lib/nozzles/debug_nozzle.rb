class DebugNozzle < Nozzle
  def stank?(file)
    return true unless params['pattern']
    file =~ Regexp.new(params['pattern'])
  end

  def spray(file)
    puts "parameters [#{params.inspect}]" if params.keys.size > 0 and verbose?
    puts file
  end

  private
  
  def filename
    __FILE__
  end
end
