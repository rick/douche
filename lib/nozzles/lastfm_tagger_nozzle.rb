require 'rubygems'
require 'mp3info'
require 'sweeper'
require 'nozzle'

@@sweeper = Sweeper.new

class LastfmTaggerNozzle < Nozzle
  def stank?(file)
    return false if params['pattern'] and ! (file =~ Regexp.new(params['pattern']))
    return false if douched?(file)
    ! already_tagged?(file)
  end

  def spray(file)
    puts "Looking up last.fm tags for [#{file}]..."
    return false unless lastfm_tag(file)
    douched(file)
    true
  end

  def lastfm_tag(file)
    tags = sweeper.lookup(file)
    return false unless tags
    return false unless tags['title'] and tags['title'].strip != ''
    return false unless tags['artist'] and tags['artist'].strip != ''
    return false unless tags['url'] and tags['url'].strip != ''
    return tag_file(file, tags)
  rescue Exception => e
    puts "Warning: last.fm tagger raised error [#{e.to_s}]"
    return false
  end

  def already_tagged?(file)
    info = Mp3Info.open(file)
    return false unless info.tag2.UFID and info.tag2.UFID.strip != ''
    true
  rescue Exception => e
    puts "Warning: reading id3v2 tags failed [#{e.to_s}]"
    return false
  end

  def tag_file(file, tags)
    puts "Tagging file [#{file}] with tags URL=[#{tags['url']}], artist=[#{tags['artist']}], title=[#{tags['title']}]"
    Mp3Info.open(file) do |mp3|
      mp3.tag2.TIT2 = tags['title']
      mp3.tag2.TPE1 = tags['artist']
      mp3.tag2.UFID = tags['url']
    end
    return true
  rescue Exception => e
    puts "Warning: tagging file encountered error [#{e.to_s}]"
    return false
  end

  private

  def filename
    __FILE__
  end

  def sweeper
    @@sweeper
  end
end
