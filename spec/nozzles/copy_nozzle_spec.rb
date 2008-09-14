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
          
          it 'should not copy the file'
        end
        
        describe 'if the file has not been processed before' do
          before :each do
            stub(@nozzle).douched?(@file) { false }
          end
          
          it 'should copy the file to the destination'
        end
      end
    end

  describe 'when spraying a file' do
      it 'should accept a filename' do
        lambda { @nozzle.spray(:foo) }.should_not raise_error(ArgumentError)
      end

      it 'should require a filename' do
        lambda {  @nozzle.spray }.should raise_error(ArgumentError)
      end
    end
  end
end

