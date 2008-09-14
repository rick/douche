require 'nozzle'

class CopyNozzle < Nozzle
  def stank?(file)
    raise ":destination parameter is required" unless params[:destination]
    ! douched?(file)
  end

  def spray(file)
    if copy(file, File.join(params[:destination], relative_path(file), File.basename(file)))
      douched(file)
      return true
    end
    false
  end

  private
  
  def filename
    __FILE__
  end
end
