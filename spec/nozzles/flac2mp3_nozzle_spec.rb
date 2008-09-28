require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

require 'find'
require 'douche_config'
require 'nozzles/flac2mp3_nozzle'

describe Flac2Mp3Nozzle do
  before :each do
    @config = DoucheConfig.new(:directory => '/path/to/something')
  end
  
  describe 'when initializing' do
    it 'should accept a config object' do
      lambda { Flac2Mp3Nozzle.new(:foo) }.should_not raise_error(ArgumentError)
    end
    
    it 'should require a config object' do
      lambda { Flac2Mp3Nozzle.new }.should raise_error(ArgumentError)
    end
    
    it 'should return a Nozzle' do
      Flac2Mp3Nozzle.new(@config).is_a?(Nozzle).should be_true
    end
  end
  
  describe 'once initialized' do
    before :each do
      @options = { :directory => '/path/to' }
      @gyno = Gynecologist.new(@options)
      @nozzle = Flac2Mp3Nozzle.new(@config)
      stub(@nozzle).status { @gyno }
      @name = 'copy'
      stub(@nozzle).name { @name }
      stub(@nozzle).params { { } }
      @file = '/path/to/some_file'
    end
    
    describe 'when checking if a file is stank' do
      it 'should accept a filename' do
        lambda { @nozzle.stank?(:foo) }.should_not raise_error(ArgumentError)
      end
      
      it 'should require a filename' do
        lambda { @nozzle.stank? }.should raise_error(ArgumentError)        
      end

      describe 'when there is a pattern specified in params and the file does not match' do
        before :each do          
          stub(@nozzle).params { { 'pattern' => '\.flac$' } }
        end
        
        it 'should return false' do
          @nozzle.stank?('/path/to/some.mp3').should be_false
        end
      end
      
      it "should check if the file has already been processed before" do
        mock(@nozzle).douched?(@file)
        @nozzle.stank?(@file)
      end
      
      describe 'if the file has already been processed before' do
        before :each do
          stub(@nozzle).douched?(@file) { true }
        end
        
        it 'should return false' do
          @nozzle.stank?(@file).should be_false
        end
      end
      
      describe 'if the file has not been processed before' do
        before :each do
          stub(@nozzle).douched?(@file) { false }
        end
        
        it 'should return true' do
          @nozzle.stank?(@file).should be_true
        end
      end
    end

    describe 'when spraying a file' do
      before :each do
        @file = '/path/to/artist/album/filename'
        @relative_path = '/artist/album'
        stub(@nozzle).params { { } }
        stub(@nozzle).relative_path { @relative_path }
        stub(@nozzle).copy(anything, anything) { true }
        stub(@nozzle).douched(@file)
        stub(@nozzle).normalize('filename') { 'normal_file' }
        stub(@nozzle).normalize(@relative_path) { 'normal_path'  }
      end
      
      it 'should accept a filename' do
        lambda { @nozzle.spray(@file) }.should_not raise_error(ArgumentError)
      end

      it 'should require a filename' do
        lambda { @nozzle.spray }.should raise_error(ArgumentError)
      end

      it 'should attempt to convert the flac to an mp3' do
        mock(Flac2mp3).convert(@file) { true }
        @nozzle.spray(@file)
      end

      describe 'if the conversion succeeds' do
        before :each do
          stub(Flac2mp3).convert(@file) { true }
        end
        
        it 'should mark the file as douched' do
          mock(@nozzle).douched(@file)
          @nozzle.spray(@file)
        end
        
        it 'should return true' do
          @nozzle.spray(@file).should be_true
        end
      end

      describe 'if the conversion fails' do
        before :each do
          stub(Flac2mp3).convert(@file) { false }
        end
        
        it 'should not mark the file as douched' do
          mock(@nozzle).douched.never
          @nozzle.spray(@file)
        end
        
        it 'should return false' do
          @nozzle.spray(@file).should be_false
        end
      end
    end
  end
end
