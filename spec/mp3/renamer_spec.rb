require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

require 'mp3/renamer'
require 'mp3/album'
require 'mp3/song'

describe MP3::Renamer do
  describe 'when initializing' do
    before :each do
      @path = '/path/to/some/mp3/dir'
    end
    
    it 'should accept a path' do
      lambda { MP3::Renamer.new(@path) }.should_not raise_error(ArgumentError)
    end
    
    it 'should require a path' do
      lambda { MP3::Renamer.new }.should raise_error(ArgumentError)
    end
  end

  describe 'once initialized' do
    before :each do
      @path = '/path/to/some/mp3/dir'
      @renamer = MP3::Renamer.new(@path)
    end
        
    it 'should allow reading the directory' do
      @renamer.should respond_to(:directory)
    end
    
    it 'should not allow writing the directory' do
      @renamer.should_not respond_to(:directory=)
    end
    
    it 'should have saved the directory provided at initialization time' do
      @renamer.directory.should == @path
    end

    it 'should be able to maintain the directory' do
      @renamer.should respond_to(:maintain)
    end

    describe 'when maintaining the directory' do
      it 'should work without arguments' do
        lambda { @renamer.maintain }.should_not raise_error(ArgumentError)
      end
      
      it 'should not allow arguments' do
        lambda { @renamer.maintain(:foo) }.should raise_error(ArgumentError)
      end
      
      it 'should show the contents of the directory' do
        mock(@renamer).show
        @renamer.maintain
      end
    end

    it 'should allow fetching our album instance' do
      @renamer.should respond_to(:album_instance)
    end

    describe 'when fetching our album instance' do
      describe 'the first time' do
        before :each do
          @album = 'album'
          stub(MP3::Album).new(@path) { @album }
        end
        
        it 'should create a new album object from our directory' do
          mock(MP3::Album).new(@path) { @album }
          @renamer.album_instance
        end
        
        it 'should return the new album object' do
          @renamer.album_instance.should == @album
        end
      end

      describe 'after the first time' do
        before :each do
          stub(MP3::Album).new(@path) { 'test' }
          @result = @renamer.album_instance
          stub(MP3::Album).new(@path) { 'fail' }
        end
        
        it 'should not create a new album object' do
          mock(MP3::Album).new(anything).never
          @renamer.album_instance
        end
        
        it 'should return the same album object as returned the first time' do
          @renamer.album_instance.should == @result
        end
      end
    end
    
    it 'should allow reading the album name' do
      @renamer.should respond_to(:album)
    end
    
    it 'should allow setting the album name' do
      @renamer.should respond_to(:album=)
    end

    describe 'when reading the album name' do
      before :each do
        @instance = 'album instance'
        stub(@instance).name { 'foo' }
        stub(@renamer).album_instance { @instance }
      end
      
      it 'should look up our album instance' do
        mock(@renamer).album_instance { @instance }
        @renamer.album
      end
      
      it 'should look up the name from our album instance' do
        mock(@instance).name
        @renamer.album
      end
      
      it "it should return our album instance's name" do
        stub(@instance).name { 'foo' }
        @renamer.album.should == 'foo'
      end
    end

    describe 'when setting the album name' do
      before :each do
        @instance = 'album instance'
        stub(@renamer).album_instance { @instance }
        stub(@instance).name=anything { 'foo' }
      end
      
      it 'should look up our album instance' do
        mock(@renamer).album_instance { @instance }
        @renamer.album = 'foo'
      end
      
      it 'should set the name on our album instance' do
        mock(@instance).name=anything { 'foo' }
        @renamer.album = 'foo'
      end      
      
      it "should return the new name" do
        (@renamer.album = 'foo').should == 'foo'
      end
    end

    it 'should allow reading the artist name' do
      @renamer.should respond_to(:artist)
    end
    
    it 'should allow setting the artist name' do
      @renamer.should respond_to(:artist=)
    end
    
    describe 'when reading the artist name' do
      before :each do
        @instance = 'album instance'
        stub(@instance).artist { 'foo' }
        stub(@renamer).album_instance { @instance }
      end
      
      it 'should look up our album instance' do
        mock(@renamer).album_instance { @instance }
        @renamer.artist
      end
      
      it 'should look up the artist from our album instance' do
        mock(@instance).artist
        @renamer.artist
      end
      
      it "it should return our album instance's artist" do
        stub(@instance).artist { 'foo' }
        @renamer.artist.should == 'foo'
      end
    end

    describe 'when setting the artist name' do
      before :each do
        @instance = 'album instance'
        stub(@renamer).album_instance { @instance }
        stub(@instance).artist=anything { 'foo' }
      end
      
      it 'should look up our album instance' do
        mock(@renamer).album_instance { @instance }
        @renamer.artist = 'foo'
      end
      
      it 'should set the artist on our album instance' do
        mock(@instance).artist=anything { 'foo' }
        @renamer.artist = 'foo'
      end      
      
      it "should return the new artist" do
        (@renamer.artist = 'foo').should == 'foo'
      end
    end

    it 'should allow reading the genre' do
      @renamer.should respond_to(:genre)
    end
    
    it 'should allow setting the genre' do
      @renamer.should respond_to(:genre=)
    end

    describe 'when reading the genre' do
      before :each do
        @instance = 'album instance'
        stub(@instance).genre { 'foo' }
        stub(@renamer).album_instance { @instance }
      end
      
      it 'should look up our album instance' do
        mock(@renamer).album_instance { @instance }
        @renamer.genre
      end
      
      it 'should look up the genre from our album instance' do
        mock(@instance).genre
        @renamer.genre
      end
      
      it "it should return our album instance's genre" do
        stub(@instance).genre { 'foo' }
        @renamer.genre.should == 'foo'
      end
    end

    describe 'when setting the genre' do
      before :each do
        @instance = 'album instance'
        stub(@renamer).album_instance { @instance }
        stub(@instance).genre=anything { 'foo' }
      end
      
      it 'should look up our album instance' do
        mock(@renamer).album_instance { @instance }
        @renamer.genre = 'foo'
      end
      
      it 'should set the genre on our album instance' do
        mock(@instance).genre=anything { 'foo' }
        @renamer.genre = 'foo'
      end      
      
      it "should return the new genre" do
        (@renamer.genre = 'foo').should == 'foo'
      end
    end

    it 'should allow reading whether the album has multiple artists' do
      @renamer.should respond_to(:multiple_artists)
    end

    it 'should allow setting whether the album has multiple artists' do
      @renamer.should respond_to(:multiple_artists=)
    end

    describe 'when reading the multiple artists value' do
      before :each do
        @instance = 'album instance'
        stub(@instance).multiple_artists { 'foo' }
        stub(@renamer).album_instance { @instance }
      end
      
      it 'should look up our album instance' do
        mock(@renamer).album_instance { @instance }
        @renamer.multiple_artists
      end
      
      it 'should look up the multiple artists value from our album instance' do
        mock(@instance).multiple_artists
        @renamer.multiple_artists
      end
      
      it "it should return our album instance's multiple artists value" do
        stub(@instance).multiple_artists { 'foo' }
        @renamer.multiple_artists.should == 'foo'
      end
    end

    describe 'when setting the multiple artists value' do
      before :each do
        @instance = 'album instance'
        stub(@renamer).album_instance { @instance }
        stub(@instance).multiple_artists=anything { 'foo' }
      end
      
      it 'should look up our album instance' do
        mock(@renamer).album_instance { @instance }
        @renamer.multiple_artists = 'foo'
      end
      
      it 'should set the multiple artists value on our album instance' do
        mock(@instance).multiple_artists=anything { 'foo' }
        @renamer.multiple_artists = 'foo'
      end      
      
      it "should return the new multiple artists value" do
        (@renamer.multiple_artists = 'foo').should == 'foo'
      end
    end

    it 'should allow looking up the songs in the album' do
      @renamer.should respond_to(:songs)
    end

    describe 'when looking up the songs in the album' do
      before :each do
        @instance = 'album instance'
        @songs = [ 1, 2, 3 ]
        stub(@instance).songs { @songs }
        stub(@renamer).album_instance { @instance }
      end
      
      it 'should look up our album instance' do
        mock(@renamer).album_instance { @instance }
        @renamer.songs
      end
      
      it 'should look up the song list from our album instance' do
        mock(@instance).songs
        @renamer.songs
      end
      
      it "should return our album instance's song list" do
        @renamer.songs.should == @songs
      end
    end
    
    it 'should be able to show the mp3s in the directory' do
      @renamer.should respond_to(:show)
    end

    describe 'when showing the mp3s in the directory' do
      before :each do
        @songs = [ @song, @song, @song]
        stub(@renamer).show_song(@song)
        stub(@renamer).songs { @songs }
        stub(@renamer).artist { 'Wank Hilliams' }
        stub(@renamer).album { 'Hatest Grits' }
        stub(@renamer).genre { 'Countries' }
        stub(@renamer).multiple_artists { 'word' }
        stub(@renamer).puts(anything)
      end
      
      it 'should work without arguments' do
        lambda { @renamer.show }.should_not raise_error(ArgumentError)
      end
      
      it 'should not allow arguments' do
        lambda { @renamer.show(:foo) }.should raise_error(ArgumentError)
      end

      it 'should look up the album name' do
        mock(@renamer).album { 'Hatest Grits' }
        @renamer.show
      end
      
      it 'should look up whether the album has multiple artists' do
        mock(@renamer).multiple_artists { true }
        @renamer.show
      end
      
      it 'should look up the album genre' do
        mock(@renamer).genre { 'Countries' }
        @renamer.show
      end
  
      it 'should look up the song list' do
        mock(@renamer).songs { @songs }
        @renamer.show
      end

      it 'should show each song' do
        mock(@renamer).show_song(@song)
        @renamer.show
      end
    end

    it 'should have a means of showing a song' do
      @renamer.should respond_to(:show_song)
    end

    describe 'when showing a song' do
      before :each do
        @song = { }
        stub(@song).title { 'Highway 61' }
        stub(@song).album { 'Highway 61 (revisited)' }
        stub(@song).artist { 'Bob Dylan' }
        stub(@renamer).puts(anything)
      end
      
      it 'should accept a song' do
        lambda { @renamer.show_song(@song) }.should_not raise_error(ArgumentError)
      end
      
      it 'should require a song' do
        lambda { @renamer.show_song }.should raise_error(ArgumentError)
      end
      
      it 'should display the song title' do
        mock(@song).title
        @renamer.show_song(@song)
      end
      
      it 'should display the song artist' do
        mock(@song).artist
        @renamer.show_song(@song)
      end
      
      it 'should display the song album' do
        mock(@song).album
        @renamer.show_song(@song)
      end
    end
  end
end
