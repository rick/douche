require 'mp3/album'

module MP3
  class Renamer
    attr_reader :directory
    attr_accessor :multiple_artists
    
    def initialize(directory)
      @directory = directory
    end

    def album_instance
      @album_instance ||= MP3::Album.new(directory)
    end

    def album
      album_instance.name
    end

    def album=(val)
      album_instance.name = val
    end
    
    def artist
      album_instance.artist
    end

    def artist=(val)
      album_instance.artist = val
    end
    
    def genre
      album_instance.genre
    end

    def genre=(val)
      album_instance.genre = val
    end
    
    def multiple_artists
      album_instance.multiple_artists
    end

    def multiple_artists=(val)
      album_instance.multiple_artists = val
    end
    
    def songs
      album_instance.songs
    end
    
    def maintain
      show
    end

    def show
      puts album + " / " + artist
      puts genre
      puts "Multiple artists? " + (multiple_artists ? 'Yes' : 'No')
      songs.each { |song| show_song(song) }
    end

    def show_song(song)
      puts "#{song.file} [#{song.name}] [#{song.artist}] [#{song.album}]"
    end
  end
end
