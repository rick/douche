require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

require 'find'
require 'douche_config'
require 'nozzles/debug_nozzle'

describe DebugNozzle do
  before :each do
    @config = DoucheConfig.new(:directory => '/path/to/something')
  end
  
  describe 'when initializing' do
    it 'should accept a config object' do
      lambda { DebugNozzle.new(:foo) }.should_not raise_error(ArgumentError)
    end
    
    it 'should require a config object' do
      lambda { DebugNozzle.new }.should raise_error(ArgumentError)
    end
    
    it 'should return a Nozzle' do
      DebugNozzle.new(@config).is_a?(Nozzle).should be_true
    end
  end
  
  describe 'once initialized' do
    before :each do
      @nozzle = DebugNozzle.new(@config)
      stub(@nozzle).params { { } }
    end
    
    describe 'when checking if a file is stank' do
      it 'should accept a filename' do
        lambda { @nozzle.stank?(:foo) }.should_not raise_error(ArgumentError)
      end
      
      it 'should require a filename' do
        lambda { @nozzle.stank? }.should raise_error(ArgumentError)        
      end
    
      describe 'when there is no pattern specified in params' do
        before :each do
          @file = '/path/to/some.mp3'
          stub(@nozzle).params { {} }
        end

        it 'should return true' do
          @nozzle.stank?(@file).should be_true
        end
      end

      describe 'when the is a pattern specified in params' do
        before :each do          
          stub(@nozzle).params { { 'pattern' => '\.mp3$' } }
        end
        
        it 'should return true if filename matches the pattern' do
          @nozzle.stank?('/path/to/some.mp3').should be_true
        end
        
        it 'should return false if filename does not match the pattern' do
          @nozzle.stank?('/path/to/some..txt').should be_false
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

      it 'should output the filename' do
        mock(@nozzle).puts('file')
        @nozzle.spray('file')
      end
    end
  end
end

