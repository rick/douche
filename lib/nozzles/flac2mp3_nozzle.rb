require 'rubygems'
require 'flac2mp3'
require 'nozzle'

class Flac2Mp3Nozzle < Nozzle
  def stank?(file)
    return false if params['pattern'] and ! (file =~ Regexp.new(params['pattern']))
    ! douched?(file)
  end

  def spray(file)
    puts "Converting flac file [#{file}] to mp3..."
    return false unless Flac2mp3.convert(file)
    douched(file)
    true
  end

  private
  
  def filename
    __FILE__
  end
end
