require 'rubygems'
require 'mp3info'
require 'nozzle'

class InitId3v2TagsNozzle < Nozzle
  def stank?(file)
    if params['pattern']
      return false if params['pattern'] and !(file =~ Regexp.new(params['pattern']))
    end
    ! douched?(file)
  end

  def spray(file)
    need = needs_v2_tags?(file)
    upgrade_tags(file) if need == :upgrade
    create_tags(file) if need == :create
    douched(file)
    return true
  rescue Exception => e
    puts "Warning: could not read id3 tags in file [#{file}] [#{e.to_s}]"
    flag_error(file)
    douched(file)
    return true
  end

  def needs_v2_tags?(file)
    info = Mp3Info.open(file)
    return false if info.hastag2?
    info.hastag1? ? :upgrade : :create
  end

  def upgrade_tags(file)
    puts "Upgrading tags from v1 to v2 for file [#{file}]"
    Mp3Info.open(file) do |mp3|
      mp3.tag2.title = mp3.tag1.title
      mp3.tag2.artist = mp3.tag1.artist
      mp3.tag2.album = mp3.tag1.album
      mp3.tag2.genre = mp3.tag1.genre
    end
  end

  def create_tags(file)
    puts "Creating empty v2 tags for file [#{file}]"
    Mp3Info.open(file) do |mp3|
      mp3.tag2.title = ''
      mp3.tag2.artist = ''
      mp3.tag2.album = ''
      mp3.tag2.genre = ''
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
