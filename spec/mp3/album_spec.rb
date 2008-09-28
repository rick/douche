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
    
    it 'should allow reading the album artist' do
      @album.should respond_to(:artist)
    end
    
    it 'should allow setting the album artist' do
      @album.should respond_to(:artist=)
    end
    
    it 'should allow reading the album genre' do
      @album.should respond_to(:genre)
    end
    
    it 'should allow setting the album genre' do
      @album.should respond_to(:genre=)
    end
    
    it 'should allow reading the album multiple artists value' do
      @album.should respond_to(:multiple_artists)
    end
    
    it 'should allow setting the album multiple artists value' do
      @album.should respond_to(:multiple_artists=)
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
      
      it 'should return a list of the files in the directory which are mp3s' do
        @album.song_files.should == ["foo.mp3", "bar.mp3"]
      end
    end
  end
end
