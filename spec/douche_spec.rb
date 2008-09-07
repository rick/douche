require File.expand_path(File.dirname(__FILE__) + '/spec_helper.rb')

require 'find'
require 'douche'
require 'nozzle'

class NozzleA < Nozzle
end

class NozzleB < Nozzle
end

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
    
    it 'should set the directory option to the provided value' do
      Douche.new(@options).directory.should == @options[:directory]
    end
    
    it 'should set the options to the provided options list' do
      Douche.new(@options).options.should == @options
    end
  end

  describe 'once initialized' do
    it 'should allow retrieving options' do
      @douche.should respond_to(:options)    
    end
  
    it 'should not allow setting options' do
      @douche.should_not respond_to(:options=)
    end
  
    it 'should allow retrieving the directory' do
      @douche.should respond_to(:directory)
    end
  
    it 'should not allow setting the directory' do
      @douche.should_not respond_to(:directory=)
    end
  
    it 'should allow retrieving the verbosity' do
      @douche.should respond_to(:verbose?)
    end
  
    it 'should not allow setting the verbosity' do
      @douche.should_not respond_to(:verbose=)
    end
    
    describe 'when retrieving the verbosity' do
      it 'should be true if douche was initialized with the option :verbose => true' do
        Douche.new(@options.merge(:verbose => true)).verbose?.should be_true
      end

      it 'should be false if douche was not initialized with the option :verbose => true' do
        Douche.new(@options).verbose?.should be_false
      end
    end
  
    describe 'when douching a path' do
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
  
    describe 'when douching a file' do
      before :each do
        @dir = File.expand_path(File.dirname(__FILE__) + '/../file_fixtures/simple')
        @douche = Douche.new(:directory => @dir)

        @config = {}
        stub(@douche).config { @config }
      
        @nozzle_a = "nozzle a"
        @nozzle_b = "nozzle b"
        stub(NozzleA).new(anything) { @nozzle_a }
        stub(NozzleB).new(anything) { @nozzle_b }
        stub(@nozzle_a).douche(anything)
        stub(@nozzle_b).douche(anything)
        stub(@douche).nozzles { [ NozzleA, NozzleB ] }
      end
    
      it 'should accept a file path' do
        lambda { @douche.douche_file(:foo) }.should_not raise_error(ArgumentError)
      end
    
      it 'should require a file path' do
        lambda { @douche.douche_file }.should raise_error(ArgumentError)
      end
    
      it 'should fetch the list of nozzles' do
        mock(@douche).nozzles { [] }
        @douche.douche_file(:file)
      end
    
      it 'should create an instance of each nozzle' do
        mock(NozzleA).new(anything) { @nozzle_a }
        mock(NozzleB).new(anything) { @nozzle_b }
        @douche.douche_file(:file)
      end
      
      it 'should pass the configuration to each nozzle' do
        mock(NozzleA).new(@config) { @nozzle_a }
        mock(NozzleB).new(@config) { @nozzle_b }
        @douche.douche_file(:file)        
      end
    
      it 'should ask each nozzle to douche the file' do
        mock(@nozzle_a).douche(:file)
        mock(@nozzle_b).douche(:file)
        @douche.douche_file(:file)      
      end

      describe 'and the verbose flag is set' do
        before :each do
          stub(@douche).verbose? { true }
        end
      
        it 'should output a nozzle notification message' do
          mock(@douche).puts(anything).times(2)
          @douche.douche_file(:file)      
        end
      end
    
      describe 'and the verbose flag is not set' do
        before :each do
          stub(@douche).verbose? { false }
        end
      
        it 'should not output a nozzle notification message' do
          mock(@douche).puts(anything).times(0)
          @douche.douche_file(:file)
        end
      end
    end

    it 'should have a means of querying the configuration' do
      @douche.should respond_to(:config)
    end

    describe 'when querying the configuration' do
      before :each do
        @config = :foo
        stub(@douche).douchebag { @douchebag }
        stub(@douchebag).config { @config }
      end
      
      it 'should work without arguments' do
        lambda { @douche.config }.should_not raise_error(ArgumentError)
      end
      
      it 'should not accept arguments' do
        lambda { @douche.config(:foo) }.should raise_error(ArgumentError)
      end
      
      it 'should look up the current douchebag' do
        mock(@douche).douchebag
        @douche.config
      end

      it "should return the douchebag's configuration object" do
        @douche.config.should == @config
      end
    end
    
    it 'should have a means of querying the current douchebag' do
      @douche.should respond_to(:douchebag)
    end
    
    describe 'when querying the current douchebag' do
      it 'should work without arguments' do
        lambda { @douche.douchebag }.should_not raise_error(ArgumentError)
      end
      
      it 'should not accept arguments' do
        lambda { @douche.douchebag(:foo) }.should raise_error(ArgumentError)
      end
      
      describe 'the first time' do
        before :each do
          @douchebag = Douchebag.new(@options)
          stub(Douchebag).new(anything) { @douchebag }
        end

        it 'should instantiate a new Douchebag instance' do
          mock(Douchebag).new(anything) { @douchebag }
          @douche.douchebag
        end
        
        it 'should pass the options list to the new Douchebag instance' do
          mock(Douchebag).new(@options) { @douchebag }
          @douche.douchebag
        end
        
        it 'should return the new Douchebag instance' do
          @douche.douchebag.should == @douchebag
        end
      end
      
      describe 'after the first time' do
        before :each do
          @results = @douche.douchebag
        end
        
        it 'should not instantiate a new Douchebag instance' do
          mock(Douchebag).new(anything).never
          @douche.douchebag          
        end
        
        it 'should return the same value it returned the first time' do
          @douche.douchebag.should == @results
        end
      end
    end
  
    describe 'when looking up nozzles' do
      before :each do
        @douche = Douche.new(@options)
        @douchebag = Douchebag.new(@options)
        stub(@douche).douchebag { @douchebag }
        stub(@douchebag).nozzles { [] }
      end
      
      it 'should accept no arguments' do
        lambda { @douche.nozzles }.should_not raise_error(ArgumentError)
      end
    
      it 'should not allow any arguments' do
        lambda { @douche.nozzles(:foo) }.should raise_error(ArgumentError)
      end
      
      describe 'the first time' do
        it 'should get the current douchebag' do
          mock(@douche).douchebag { @douchebag }
          @douche.nozzles
        end
      
        it 'should retrieve the nozzles from the douchebag' do
          mock(@douchebag).nozzles { [] }
          @douche.nozzles
        end
      
        it 'should return the nozzles found from the douchebag' do
          stub(@douchebag).nozzles { [1, 2, 3 ] }
          @douche.nozzles.should == [ 1, 2, 3]
        end
      end
      
      describe 'after the first time' do
        it 'should not get a new douchebag' do
          @douche.nozzles
          mock(Douchebag).new(anything).never
          @douche.nozzles
        end
        
        it 'should return the same nozzles as returned the first time' do
          stub(@douchebag).nozzles { [5, 4, 3]}
          @douche.nozzles
          stub(@douchebag).nozzles { [3, 2, 1]}
          @douche.nozzles.should == [ 5, 4, 3]
        end
      end
    end
  end
end
