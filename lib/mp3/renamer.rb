module MP3
  class Renamer
    attr_reader :directory
    attr_accessor :album, :artist, :genre, :multiple_artists
    
    def initialize(directory)
      @directory = directory
    end

    def maintain
      show
    end

    def show
      puts album
      puts genre
      multiple_artists
      songs
    end

    def songs
      song_files.collect { |f| Song.new(f) }
    end

    def song_files
      Dir.open(directory).to_a.select { |f| f =~ /\.mp3$/ }
    end
  end
end
