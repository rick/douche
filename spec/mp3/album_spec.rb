require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

require 'mp3/album'
require 'mp3/song'

describe MP3::Album do
  describe 'when initializing' do
    before :each do
      @path = '/path/to/some/mp3/dir'
    end
    
    it 'should accept a directory' do
      lambda { MP3::Album.new(@path) }.should_not raise_error(ArgumentError)
    end
    
    it 'should require a directory' do
      lambda { MP3::Album.new }.should raise_error(ArgumentError)
    end
  end

  describe 'once initialized' do
    before :each do
      @path = '/path/to/some/mp3/dir'
      @album = MP3::Album.new(@path)
    end
        
    it 'should allow reading the directory' do
      @album.should respond_to(:directory)
    end
    
    it 'should not allow writing the directory' do
      @album.should_not respond_to(:directory=)
    end
    
    it 'should have saved the directory provided at initialization time' do
      @album.directory.should == @path
    end

    it 'should allow reading the album name' do
      @album.should respond_to(:name)
    end
    
    it 'should allow setting the album name' do
      @album.should respond_to(:name=)
    end

    describe 'reading the album name' do
      describe 'when the album name is not yet set' do
        it 'should return the album name from the first song' do
          @songs = [ @first, 2, 3]
          stub(@album).songs { @songs }
          stub(@first).album { 'Hood on the Blighway' }
          @album.name.should == 'Hood on the Blighway'
        end
      end
      
      describe 'when the album name has been set' do
        before :each do
          @album.name = 'Hood on the Blighway'
        end

        it 'should not lookup the album name from any songs' do
          mock(@album).songs.never
          @album.name
        end
        
        it 'should return the previously set album name' do
          @album.name.should == 'Hood on the Blighway'
        end        
      end
    end

    it 'should allow reading the album artist' do
      @album.should respond_to(:artist)
    end
    
    it 'should allow setting the album artist' do
      @album.should respond_to(:artist=)
    end

    describe 'reading the album artist' do
      describe 'when the album artist is not yet set' do
        it 'should return the album artist from the first song' do
          @songs = [ @first, 2, 3]
          stub(@album).songs { @songs }
          stub(@first).artist { 'Bob Dylan' }
          @album.artist.should == 'Bob Dylan'
        end
      end
      
      describe 'when the album artist has been set' do
        before :each do
          @album.artist = 'Bob Dylan'
        end

        it 'should not lookup the artist name from any songs' do
          mock(@album).songs.never
          @album.artist
        end
        
        it 'should return the previously set artist name' do
          @album.artist.should == 'Bob Dylan'
        end
      end
    end

    it 'should allow reading the album genre' do
      @album.should respond_to(:genre)
    end
    
    it 'should allow setting the album genre' do
      @album.should respond_to(:genre=)
    end
    
    describe 'reading the album genre' do
      describe 'when the album genre is not yet set' do
        it 'should return the album genre from the first song' do
          @songs = [ @first, 2, 3]
          stub(@album).songs { @songs }
          stub(@first).genre { 'Blues' }
          @album.genre.should == 'Blues'
        end
      end
      
      describe 'when the album genre has been set' do
        before :each do
          @album.genre = 'Blues'
        end

        it 'should not lookup the genre name from any songs' do
          mock(@album).songs.never
          @album.genre
        end
        
        it 'should return the previously set genre name' do
          @album.genre.should == 'Blues'
        end
      end
    end

    it 'should allow reading the album multiple artists value' do
      @album.should respond_to(:multiple_artists)
    end
    
    it 'should allow setting the album multiple artists value' do
      @album.should respond_to(:multiple_artists=)
    end

    describe 'reading the album multiple artists value' do
      describe 'when the multiple artists value is not yet set' do
        before :each do
          @first, @second = { }, { }
          stub(@first).artist { 'Bob Dylan' }
          stub(@second).artist { 'Willie Nelson' }
        end
        
        it 'should return true if any songs have differing artists' do
          @songs = [ @first, @second, @first ]
          stub(@album).songs { @songs }
          @album.multiple_artists.should be_true
        end
        
        it 'should return false if all songs have the same artist' do
          @songs = [ @first, @first, @first ]
          stub(@album).songs { @songs }
          @album.multiple_artists.should be_false
        end
      end
      
      describe 'when the album multiple artists value has been set' do
        before :each do
          @album.multiple_artists = :foo
        end

        it 'should not lookup the genre name from any songs' do
          mock(@album).songs.never
          @album.multiple_artists
        end
        
        it 'should return the previously set genre name' do
          @album.multiple_artists.should == :foo
        end
      end
    end

    describe 'when looking up the songs in the album' do
      before :each do
        @files = [ "foo.mp3", "bar.mp3" ]
      end
      
      it 'should work without arguments' do
        lambda { @album.songs }.should_not raise_error(ArgumentError)
      end
      
      it 'should allow no arguments' do
        lambda { @album.songs(:foo) }.should raise_error(ArgumentError)
      end

      describe 'the first time' do
        before :each do
          stub(@album).song_files { @files }
          @files.each do |f|
            stub(MP3::Song).new(f) { "#{f}-song" }
          end
        end
        
        it 'should retrieve the list of song files in the directory' do
          mock(@album).song_files { @files }
          @album.songs
        end
        
        it 'should create a new song object for each song file in the directory' do
          @files.each do |file|
            mock(MP3::Song).new(file)
          end
          @album.songs
        end
        
        it 'should return a list of the new song objects' do
          @album.songs.should == [ "foo.mp3-song", "bar.mp3-song" ]
        end
      end

      describe 'after the first time' do
        before :each do
          stub(@album).song_files { @files }
          @files.each do |f|
            stub(MP3::Song).new(f) { "#{f}-song" }
          end

          @result = @album.songs
        end
        
        it 'should not look up song files' do
          mock(@album).song_files.never
          @album.songs
        end
        
        it 'should not create new song objects' do
          mock(MP3::Song).new(anything).never
          @album.songs
        end
        
        it 'should return the same results as were returned the first time' do
          @album.songs.should == @result
        end
      end
    end

    it 'should provide a means of finding all the song files in the directory' do
      @album.should respond_to(:song_files)
    end

    describe 'when finding all the song files in the directory' do
      before :each do
        @files = [ "foo.mp3", "bar.mp3", "biz.m3u", "cover.jpg" ]
        stub(Dir).open(@path) { @files }
      end
      
      it 'should work without arguments' do
        lambda { @album.song_files }.should_not raise_error(ArgumentError)
      end
      
      it 'should not allow arguments' do
        lambda { @album.song_files(:foo) }.should raise_error(ArgumentError)
      end
      
      it 'should query the files in the directory' do
        mock(Dir).open(@path) { @files }
        @album.song_files
      end
      
      it 'should return a list of the full paths to files in the directory which are mp3s' do
        @album.song_files.should == [File.join(@path, "foo.mp3"), File.join(@path, "bar.mp3") ]
      end
    end
  end
end
