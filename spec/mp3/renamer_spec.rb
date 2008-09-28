require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

require 'mp3/renamer'
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

    it 'should allow reading the album name' do
      @renamer.should respond_to(:album)
    end
    
    it 'should allow setting the album name' do
      @renamer.should respond_to(:album=)
    end
    
    it 'should allow reading the artist name' do
      @renamer.should respond_to(:artist)
    end
    
    it 'should allow setting the artist name' do
      @renamer.should respond_to(:artist=)
    end
    
    it 'should allow reading the genre' do
      @renamer.should respond_to(:genre)
    end
    
    it 'should allow setting the genre' do
      @renamer.should respond_to(:genre=)
    end

    it 'should allow reading whether the album has multiple artists' do
      @renamer.should respond_to(:multiple_artists)
    end

    it 'should allow setting whether the album has multiple artists' do
      @renamer.should respond_to(:multiple_artists=)
    end

    it 'should allow looking up the songs in the album' do
      @renamer.should respond_to(:songs)
    end

    describe 'when looking up the songs in the album' do
      before :each do
        @files = [ "foo.mp3", "bar.mp3" ]
        stub(@renamer).song_files { @files }
        @files.each do |f|
          stub(MP3::Song).new(f) { "#{f}-song" }
        end
      end
      
      it 'should work without arguments' do
        lambda { @renamer.songs }.should_not raise_error(ArgumentError)
      end
      
      it 'should allow no arguments' do
        lambda { @renamer.songs(:foo) }.should raise_error(ArgumentError)
      end

      it 'should retrieve the list of song files in the directory' do
        mock(@renamer).song_files { @files }
        @renamer.songs
      end

      it 'should create a new song object for each song file in the directory' do
        @files.each do |file|
          mock(MP3::Song).new(file)
        end
        @renamer.songs
      end

      it 'should return a list of the new song objects' do
        @renamer.songs.should == [ "foo.mp3-song", "bar.mp3-song" ]
      end
    end

    it 'should provide a means of finding all the song files in the directory' do
      @renamer.should respond_to(:song_files)
    end

    describe 'when finding all the song files in the directory' do
      before :each do
        @files = [ "foo.mp3", "bar.mp3", "biz.m3u", "cover.jpg" ]
        stub(Dir).open(@path) { @files }
      end
      
      it 'should work without arguments' do
        lambda { @renamer.song_files }.should_not raise_error(ArgumentError)
      end
      
      it 'should not allow arguments' do
        lambda { @renamer.song_files(:foo) }.should raise_error(ArgumentError)
      end
      
      it 'should query the files in the directory' do
        mock(Dir).open(@path) { @files }
        @renamer.song_files
      end
      
      it 'should return a list of the files in the directory which are mp3s' do
        @renamer.song_files.should == ["foo.mp3", "bar.mp3"]
      end
    end
    
    it 'should be able to show the mp3s in the directory' do
      @renamer.should respond_to(:show)
    end

    describe 'when showing the mp3s in the directory' do
      before :each do
        stub(@renamer).songs { [1, 2, 3] }
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
        mock(@renamer).songs { [1, 2, 3] }
        @renamer.show
      end
    end
  end
end

