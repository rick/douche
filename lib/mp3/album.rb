require 'mp3/song'

module MP3
  class Album
    attr_reader :directory
    attr_accessor :name, :artist, :genre, :multiple_artists
    
    def initialize(directory)
      @directory = directory
    end

    def songs
      @songs ||= song_files.collect { |f| Song.new(f) }
    end
    
    def song_files
      Dir.open(directory).to_a.select { |f| f =~ /\.mp3$/ }
    end
  end
end
