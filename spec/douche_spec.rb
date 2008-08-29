require File.expand_path(File.dirname(__FILE__) + '/spec_helper.rb')

require 'find'
require 'douche'

describe Douche do
  before :each do
    @options = { :directory => '/tmp/'}
    @douche = Douche.new(@options)
  end

  describe 'when initializing' do
    it 'should accept options' do
      lambda { Douche.new(@options) }.should_not raise_error(ArgumentError)
    end
    
    it 'should require options' do
      lambda { Douche.new }.should raise_error(ArgumentError)
    end
    
    it 'should fail if no directory is provided' do
      lambda { Douche.new(@options.merge({:directory => nil})) }.should raise_error(ArgumentError)
    end
    
    it 'should set the directory option to the provided value' do |variable|
      Douche.new(@options).directory.should == @options[:directory]
    end
  end
  
  it 'should allow retrieving the directory' do
    @douche.should respond_to(:directory)
  end
  
  it 'should not allow setting the directory' do
    @douche.should_not respond_to(:directory=)
  end
  
  it 'should allow retrieving the dry-run status' do
    @douche.should respond_to(:dry_run?)
  end
  
  it 'should not allow setting the dry-run status' do
    @douche.should_not respond_to(:dry_run=)
  end
  
  describe 'dry run?' do
    it 'should be true if initialized with :dry_run => true' do
      Douche.new(@options.merge(:dry_run => true)).dry_run?.should be_true
    end

    it 'should be true if not initialized with :dry_run => true' do
      Douche.new(@options).dry_run?.should be_false
    end
  end
  
  describe 'douche' do
    before :each do
      @dir = File.expand_path(File.dirname(__FILE__) + '/../file_fixtures/simple')
      @douche = Douche.new(:directory => @dir)
    end
    
    it 'should work without arguments' do
      lambda { @douche.douche }.should_not raise_error(ArgumentError)
    end
    
    it 'should not accept any arguments' do
      lambda { @douche.douche(:foo) }.should raise_error(ArgumentError)
    end
    
    it 'should douche all files under the current directory' do
      Find.find(@dir) do |path|
        mock(@douche).douche_file(path) if File.file? path
      end
      @douche.douche
    end
  end
  
  describe 'douching a file' do
    before :each do
      @dir = File.expand_path(File.dirname(__FILE__) + '/../file_fixtures/simple')
      @douche = Douche.new(:directory => @dir)
    end
    
    it 'should accept a file path' do
      lambda { @douche.douche_file(:foo) }.should_not raise_error(ArgumentError)
    end
    
    it 'should require a file path' do
      lambda { @douche.douche_file }.should raise_error(ArgumentError)
    end
  end
end
