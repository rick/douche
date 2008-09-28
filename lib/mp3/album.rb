require 'mp3/song'

module MP3
  class Album
    attr_reader :directory
    attr_writer :name, :artist, :genre, :multiple_artists
    
    def initialize(directory)
      @directory = directory
    end

    def songs
      @songs ||= song_files.collect { |f| Song.new(f) }
    end
    
    def song_files
      Dir.open(directory).to_a.select { |f| f =~ /\.mp3$/ }.collect { |f| File.join(directory, f) }
    end

    def name
      @name ||= songs.first.album
    end

    def artist
      @artist ||= songs.first.artist
    end

    def genre
      @genre ||= songs.first.genre
    end

    def multiple_artists
      return @multiple_artists if @multiple_artists
      song_list = songs
      @multiple_artists = song_list.any? {|song| song.artist != song_list.first.artist }
    end
  end
end
