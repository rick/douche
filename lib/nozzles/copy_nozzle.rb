require 'nozzle'

class CopyNozzle < Nozzle
  def stank?(file)
    raise ":destination parameter is required" unless params[:destination]
    douched?(file)
  end

  def spray(file)
  end

  private
  
  def filename
    __FILE__
  end
end
