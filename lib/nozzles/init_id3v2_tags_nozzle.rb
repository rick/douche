require 'rubygems'
require 'mp3info'
require 'nozzle'

class InitId3v2TagsNozzle < Nozzle
  def stank?(file)
    return false if params['pattern'] and !(file =~ Regexp.new(params['pattern']))
    ! douched?(file)
  end

  def spray(file)
    upgrade_tags(file) if needs_v2_tags?(file)
  rescue Exception => e
    puts "Warning: could not read id3 tags in file [#{file}] [#{e.to_s}]"
    flag_error(file)
  ensure
    douched(file)
    return true
  end

  def needs_v2_tags?(file)
    info = Mp3Info.open(file)
    ! info.hastag2?
  end

  def upgrade_tags(file)
    puts "Upgrading tags to id3v2 for file [#{file}]"
    Mp3Info.open(file) do |mp3|
      mp3.tag2.TCON = '(%02d)' % (mp3.tag1['genre'] ||'').to_s.gsub(/[()]/, '').to_i
      mp3.tag2.TIT2 = (mp3.tag1['title']  || '').strip
      mp3.tag2.TPE1 = (mp3.tag1['artist'] || '').strip
      mp3.tag2.TALB = (mp3.tag1['album']  || '').strip
      mp3.flush
    end
  end
  
  def flag_error(file)
    File.open(File.join(File.dirname(file), ".douche_error_encoding-#{File.basename(file, '.mp3')}"), 'w')
  end

  private
  
  def filename
    __FILE__
  end
end
