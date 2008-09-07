class TrueNozzle < Nozzle
  def stank?(file)
    file =~ /\.txt$/
  end

  def spray(file)
    puts ":::::: #{file}"
  end
end
