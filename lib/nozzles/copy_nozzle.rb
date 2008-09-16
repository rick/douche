require 'nozzle'

class CopyNozzle < Nozzle
  def stank?(file)
    raise ":destination parameter is required" unless params[:destination]
    ! douched?(file)
  end

  def spray(file)
    normal_relative = normalize(relative_path(file))
    normal_file = normalize(File.basename(file))
    if copy(file, File.join(params[:destination], normal_relative, normal_file))
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
