require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

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
    
    it 'should not allow writing the file path' do
      @song.should_not respond_to(:file=)
    end
    
    it 'should have saved the file path provided at initialization time' do
      @song.file.should == @path
    end
  end
end
