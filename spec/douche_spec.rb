require File.expand_path(File.dirname(__FILE__) + '/spec_helper.rb')

require 'find'
require 'douche'
require 'nozzle'

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
    
    it 'should fetch the list of nozzles' do
      mock(@douche).nozzles { [] }
      @douche.douche_file(:foo)
    end
  end
  
  describe 'when looking up nozzles' do
    before :each do
      @dir = File.expand_path(File.dirname(__FILE__) + '/../file_fixtures/simple')
      @douche = Douche.new(:directory => @dir)
      stub(Nozzle).nozzles { [] }
    end
    
    it 'should accept no arguments' do
      lambda { @douche.nozzles }.should_not raise_error(ArgumentError)
    end
    
    it 'should not allow any arguments' do
      lambda { @douche.nozzles(:foo) }.should raise_error(ArgumentError)
    end
    
    describe 'the first time' do      
      it 'should look up the nozzles path' do
        mock(@douche).nozzle_path { '/path/to/nozzles' }
        stub(Find).find('/path/to/nozzles') { [] }
        @douche.nozzles
      end
    
      it 'should find all nozzles in the nozzles path' do
        stub(@douche).nozzle_path { '/path/to/nozzles' }
        mock(Find).find('/path/to/nozzles') { [] }
        @douche.nozzles
      end
    
      it 'should instantiate the nozzle objects' do
        @path = File.expand_path(File.dirname(__FILE__) + '/../file_fixtures/nozzles/')
        stub(@douche).nozzle_path { @path }
        Find.find(@path) {|path| mock(@douche).require path if File.file? path }
        @douche.nozzles
      end
      
      it 'should return the final list of nozzles' do
        stub(Nozzle).nozzles { [ 1, 2, 3 ] }
        @douche.nozzles.should == [ 1, 2, 3 ]
      end
    end
    
    describe 'after the first time' do
      before :each do
        @path = File.expand_path(File.dirname(__FILE__) + '/../file_fixtures/nozzles/')
        stub(@douche).nozzle_path { @path }
      end
      
      it 'should not look up the nozzles path' do
        @douche.nozzles
        mock(@douche).nozzle_path.times(0)
        @douche.nozzles
      end
      
      it 'should not find nozzles' do
        @douche.nozzles
        mock(Find).find.times(0)
        @douche.nozzles
      end
      
      it 'should not instantiate nozzles' do
        @douche.nozzles
        mock(@douche).require.times(0)
        @douche.nozzles
      end
      
      it 'should return the same list of nozzles as returned the first time' do
        result = @douche.nozzles
        @douche.nozzles.should == result
      end
    end
  end
  
  describe 'nozzle path' do
    it 'should accept no arguments' do
      lambda { @douche.nozzle_path }.should_not raise_error(ArgumentError)
    end
    
    it 'should allow no arguments' do
      lambda { @douche.nozzle_path(:foo) }.should raise_error(ArgumentError)
    end
    
    it 'should return the path for lib/nozzles' do
      @douche.nozzle_path.should == File.expand_path(File.dirname(__FILE__) + '/../lib/nozzles/')
    end
  end
end
