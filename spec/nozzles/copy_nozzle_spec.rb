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
      @nozzle = CopyNozzle.new(@config)
      @file = '/path/to/some_file'
    end
    
    describe 'when checking if a file is stank' do
      it 'should accept a filename' do
        lambda { @nozzle.stank?(:foo) }.should_not raise_error(ArgumentError)
      end
      
      it 'should require a filename' do
        lambda { @nozzle.stank? }.should raise_error(ArgumentError)        
      end

      it "should look up the path to the nozzle's status file" do
        mock(@nozzle).status_file(@file) { '/path/to/status_file' }
        @nozzle.stank?(@file)
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

