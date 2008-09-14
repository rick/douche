require 'nozzle'

class CopyNozzle < Nozzle
  def stank?(file)
    status_file file
  end

  def spray(file)
  end

  private
  
  def filename
    __FILE__
  end
end
