require 'rubygems'
require 'mp3info'

module MP3
  class Song
    attr_accessor :file

    def initialize(file)
      @file = file
    end

    def tag(key)
      Mp3Info.open(file).tag[key.to_s]
    end

    def set_tag(key, val)
      Mp3Info.open(file) {|mp3| mp3.tag[key.to_s] = val }
      val
    end

    def name
      tag(:title)
    end

    def name=(val)
      set_tag(:title, val)
    end

    def artist
      tag(:artist)
    end

    def artist=(val)
      set_tag(:artist, val)
    end

    def album
      tag(:album)
    end

    def album=(val)
      set_tag(:album, val)
    end

    def genre
      tag(:genre_s)
    end

    def genre=(val)
      set_tag(:genre_s, val)
    end

    def modified
      File.mtime(file)
    end

    def length
      Mp3Info.open(file).length
    end

    def bitrate
      Mp3Info.open(file).bitrate
    end
  end
end
