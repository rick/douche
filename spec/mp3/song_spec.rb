require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

require 'mp3info'
require 'mp3/song'

describe MP3::Song do
  describe 'when initializing' do
    before :each do
      @path = '/path/to/some/mp3/dir/foo.mp3'
    end
    
    it 'should accept a file path' do
      lambda { MP3::Song.new(@path) }.should_not raise_error(ArgumentError)
    end
    
    it 'should require a path' do
      lambda { MP3::Song.new }.should raise_error(ArgumentError)
    end
  end

  describe 'once initialized' do
    before :each do
      @path = '/path/to/some/mp3/dir/foo.mp3'
      @song = MP3::Song.new(@path)
    end
        
    it 'should allow reading the file path' do
      @song.should respond_to(:file)
    end
    
    it 'should allow writing the file path' do
      @song.should respond_to(:file=)
    end
    
    it 'should have saved the file path provided at initialization time' do
      @song.file.should == @path
    end

    it 'should allow reading the track name' do
      @song.should respond_to(:name)
    end

    it 'should allow setting the track name' do
      @song.should respond_to(:name=)
    end

    describe 'when reading the track name' do
      it 'should return the title id3 tag from the file' do
        mock(@song).tag(:title) { 'Saucemaster' }
        @song.name.should == 'Saucemaster'
      end
    end
    
    describe 'when setting the track name' do
      it 'should write the title id3 tag to the file' do
        mock(@song).set_tag(:title, 'Saucemaster') { 'Saucemaster' }
        (@song.name= 'Saucemaster').should == 'Saucemaster'
      end
    end
    
    it 'should allow reading the artist name' do
      @song.should respond_to(:artist)
    end
    
    it 'should allow setting the artist name' do
      @song.should respond_to(:artist=)
    end
    
    describe 'when reading the artist name' do
      it 'should return the artist id3 tag from the file' do
        mock(@song).tag(:artist) { 'Bob Dylan' }
        @song.artist.should == 'Bob Dylan'
      end
    end
    
    describe 'when setting the artist name' do
      it 'should write the title id3 tag to the file' do
        mock(@song).set_tag(:artist, 'Bob Dylan') { 'Bob Dylan' }
        (@song.artist = 'Bob Dylan').should == 'Bob Dylan'
      end
    end
    
    it 'should allow reading the album name' do
      @song.should respond_to(:album)
    end
    
    it 'should allow setting the album name' do
      @song.should respond_to(:album=)
    end
    
    describe 'when reading the album name' do
      it 'should return the album id3 tag from the file' do
        mock(@song).tag(:album) { 'Bob Dylan' }
        @song.album.should == 'Bob Dylan'
      end
    end
    
    describe 'when setting the album name' do
      it 'should write the title id3 tag to the file' do
        mock(@song).set_tag(:album, 'Bob Dylan') { 'Bob Dylan' }
        (@song.album = 'Bob Dylan').should == 'Bob Dylan'
      end
    end
    
    it 'should allow reading the genre' do
      @song.should respond_to(:genre)
    end
    
    it 'should allow setting the genre' do
      @song.should respond_to(:genre=)
    end
        
    describe 'when reading the genre' do
      it 'should return the genre id3 tag from the file' do
        mock(@song).tag(:genre_s) { 'Blues' }
        @song.genre.should == 'Blues'
      end
    end
    
    describe 'when setting the genre' do
      it 'should write the title id3 tag to the file' do
        mock(@song).set_tag(:genre_s, 'Blues') { 'Blues' }
        (@song.genre = 'Blues').should == 'Blues'
      end
    end
    
    it 'should allow reading the last modification time' do
      @song.should respond_to(:modified)
    end

    describe 'when reading the last modification time' do
      it 'should return the modification time for our file' do
        @time = Time.now
        mock(File).mtime(@path) { @time }
        @song.modified.should == @time
      end
    end
    
    it 'should allow reading the track length' do
      @song.should respond_to(:length)
    end

    describe 'when returning the track length' do
      it 'should return the mp3 length for our file' do
        @info = 'info'
        stub(@info).length { 123 }
        stub(Mp3Info).open(@path) { @info }
        @song.length.should == 123
      end
    end
    
    it 'should allow reading the bitrate' do
      @song.should respond_to(:bitrate)
    end

    describe 'when reading the bitrate' do
      it 'should return the mp3 bitrate for our file' do
        @info = 'info'
        stub(@info).bitrate { 192 }
        stub(Mp3Info).open(@path) { @info }
        @song.bitrate.should == 192
      end        
    end    

    it 'should allow reading an id3 tag' do
      @song.should respond_to(:tag)
    end

    describe 'when reading an id3 tag' do
      before :each do
        @tags = 'tags'
        stub(@tags).tag { { 'artist' => 'Bob Dylan' } }
        stub(Mp3Info).open(@path) { @tags }
      end
      
      it 'should allow a tag name' do
        lambda { @song.tag(:artist) }.should_not raise_error(ArgumentError)
      end
      
      it 'should require a tag name' do
        lambda { @song.tag }.should raise_error(ArgumentError)
      end
      
      it 'should read the tags from our file' do
        mock(Mp3Info).open(@path) { @tags }
        @song.tag(:artist)
      end
      
      it 'should return the value for the named tag' do
        @song.tag('artist').should == 'Bob Dylan'
      end
    end

    it 'should allow setting an id3 tag' do
      @song.should respond_to(:set_tag)
    end
    
    describe 'when setting an id3 tag' do
      before :each do
        @tags = 'tags'
        stub(@tags).tag { { :artist => 'Bob Dylan' } }
        stub(Mp3Info).open(@path) { @tags }
      end
      
      it 'should allow a tag name and a value' do
        lambda { @song.set_tag(:artist, 'Bob Dylan') }.should_not raise_error(ArgumentError)
      end
      
      it 'should require a tag name and a value' do
        lambda { @song.set_tag(:artist) }.should raise_error(ArgumentError)
      end
      
      it 'should update the tags for our file' do
        mock(Mp3Info).open(@path) { @tags }
        @song.set_tag(:artist, 'Bob Dylan')
      end

      it 'should set the tag to the specified value' do
        pending ("figuring out how to test this")
      end
      
      it 'should return the value for the named tag' do
        @song.set_tag(:artist, 'Bob Dylan').should == 'Bob Dylan'
      end
    end
  end
end
