require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

require 'find'
require 'douche_config'
require 'nozzles/copy_nozzle'

describe CopyNozzle do
  before :each do
    @config = DoucheConfig.new(:directory => '/path/to/something')
  end
  
  describe 'when initializing' do
    it 'should accept a config object' do
      lambda { CopyNozzle.new(:foo) }.should_not raise_error(ArgumentError)
    end
    
    it 'should require a config object' do
      lambda { CopyNozzle.new }.should raise_error(ArgumentError)
    end
    
    it 'should return a Nozzle' do
      CopyNozzle.new(@config).is_a?(Nozzle).should be_true
    end
  end
  
  describe 'once initialized' do
    before :each do
      @options = { :directory => '/path/to' }
      @gyno = Gynecologist.new(@options)
      @nozzle = CopyNozzle.new(@config)
      stub(@nozzle).status { @gyno }
      @name = 'copy'
      stub(@nozzle).name { @name }
      @file = '/path/to/some_file'
    end
    
    describe 'when checking if a file is stank' do
      it 'should accept a filename' do
        lambda { @nozzle.stank?(:foo) }.should_not raise_error(ArgumentError)
      end
      
      it 'should require a filename' do
        lambda { @nozzle.stank? }.should raise_error(ArgumentError)        
      end

      describe 'when there is no destination' do
        before :each do
          stub(@nozzle).params { { } }
        end
        
        it 'should fail' do
          lambda { @nozzle.stank?(@file) }.should raise_error
        end
      end

      describe 'when there is a destination' do
        before :each do
          stub(@nozzle).params { { :destination => '/path/to/destination' } }
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
    end

    describe 'when spraying a file' do
      before :each do
        @file = '/path/to/artist/album/filename'
        @relative_path = '/artist/album'
        @destination = '/destination/place'
        stub(@nozzle).params { { :destination => @destination} }
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

      it 'should look up the relative path to the file' do
        mock(@nozzle).relative_path(@file) { @relative_path }
        @nozzle.spray(@file)
      end

      it 'should normalize the relative path to the file' do
        mock(@nozzle).normalize(@relative_path) { 'normal_path' }
        @nozzle.spray(@file)
      end
      
      it 'should normalize the filename' do
        mock(@nozzle).normalize('filename') { 'normal_file' }
        @nozzle.spray(@file)
      end

      it 'should attempt to copy the file to the destination using normalized paths' do
        mock(@nozzle).copy(@file, File.join(@destination, 'normal_path', 'normal_file')) { true }
        @nozzle.spray(@file)
      end

      describe 'if the copy succeeds' do
        before :each do
          stub(@nozzle).copy(anything, anything) { true }
        end
        
        it 'should mark the file as douched' do
          mock(@nozzle).douched(@file)
          @nozzle.spray(@file)
        end
        
        it 'should return true' do
          @nozzle.spray(@file).should be_true
        end
      end

      describe 'if the copy fails' do
        before :each do
          stub(@nozzle).copy(anything, anything) { false }
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
