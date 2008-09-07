require File.expand_path(File.dirname(__FILE__) + '/spec_helper.rb')

require 'find'
require 'douchebag'

describe Douchebag do
  before :each do
    @options = { :directory => '/tmp/'}
    @douchebag = Douchebag.new(@options)
  end

  describe 'when initializing' do
    it 'should accept options' do
      lambda { Douchebag.new(@options) }.should_not raise_error(ArgumentError)
    end
    
    it 'should require options' do
      lambda { Douchebag.new }.should raise_error(ArgumentError)
    end
    
    it 'should fail if no directory is provided' do
      lambda { Douchebag.new(@options.merge({:directory => nil})) }.should raise_error(ArgumentError)
    end
    
    it 'should set the directory option to the provided value' do
      Douchebag.new(@options).directory.should == @options[:directory]
    end
    
    it 'should set the options to the provided options list' do
      Douchebag.new(@options).options.should == @options
    end
  end

  describe 'once initialized' do
    it 'should allow retrieving options' do
      @douchebag.should respond_to(:options)    
    end
  
    it 'should not allow setting options' do
      @douchebag.should_not respond_to(:options=)
    end
  
    it 'should allow retrieving the directory' do
      @douchebag.should respond_to(:directory)
    end
  
    it 'should not allow setting the directory' do
      @douchebag.should_not respond_to(:directory=)
    end
  
    it 'should allow retrieving the verbosity' do
      @douchebag.should respond_to(:verbose?)
    end
  
    it 'should not allow setting the verbosity' do
      @douchebag.should_not respond_to(:verbose=)
    end
    
    it 'should allow retrieving the configuration' do
      @douchebag.should respond_to(:config)
    end
    
    it 'should not allow setting the configuration' do
      @douchebag.should_not respond_to(:config=)
    end

    describe 'when retrieving the verbosity' do
      it 'should be true if douchebag was initialized with the option :verbose => true' do
        Douchebag.new(@options.merge(:verbose => true)).verbose?.should be_true
      end

      it 'should be false if douchebag was not initialized with the option :verbose => true' do
        Douchebag.new(@options).verbose?.should be_false
      end
    end
    
    describe 'when retrieving the config' do
      before :each do
        stub(DoucheConfig).new(anything) { {} }
      end
      
      describe 'the first time' do
        it 'should create a new douche config' do
          mock(DoucheConfig).new(anything) { {} }
          @douchebag.config
        end
        
        it 'should supply the douche config with our options' do
          mock(DoucheConfig).new(@options) { {} }
          @douchebag.config          
        end
        
        it 'should return the douche config' do
          @douchebag.config.should == {}
        end
      end
      
      describe 'after the first time' do
        before :each do
          @results = @douchebag.config
        end
        
        it 'should not create a new douche config' do
          mock(DoucheConfig).new(anything).never
          @douchebag.config
        end
        
        it 'should return the same douche config as was returned the first time' do
          @douchebag.config.should == @results
        end
      end
    end
  
    describe 'when looking up nozzles' do
      before :each do
        @dir = '/path/to/someplace'
        @douchebag = Douchebag.new(:directory => @dir)
        
        @doucheconfig = {}
        stub(@doucheconfig).nozzles { [ 1, 2, 3 ] }
        stub(@douchebag).config { @doucheconfig }
        
        stub(@douchebag).nozzle_file(anything) { "/path/to/nozzle.rb" }
        stub(@douchebag).require(anything) { true }
      end
    
      it 'should accept no arguments' do
        lambda { @douchebag.nozzles }.should_not raise_error(ArgumentError)
      end
    
      it 'should not allow any arguments' do
        lambda { @douchebag.nozzles(:foo) }.should raise_error(ArgumentError)
      end
    
      describe 'the first time' do
        it 'should get a list of nozzles from the doucheconfig' do
          mock(@doucheconfig).nozzles { [ 1, 2, 3 ] }
          @douchebag.nozzles
        end
        
        describe 'if no nozzles are found' do
          before :each do
            stub(@doucheconfig).nozzles { [] }
            stub(@doucheconfig).config_path { '/path/to/config.yml' }
          end
          
          it 'should fail' do
            lambda { @douchebag.nozzles }.should raise_error
          end
        end

        describe 'if nozzles are found' do
          before :each do
            @nozzles = [ 'foo', 'bar', 'baz' ]
            stub(@doucheconfig).nozzles { @nozzles }
          end
          
          it 'should look up the filename for each nozzle' do
            @nozzles.each do |nozzle|
              mock(@douchebag).nozzle_file(nozzle) { "/path/to/#{nozzle}_nozzle.rb" }
            end
            @douchebag.nozzles
          end

          it 'should instantiate each nozzle object from the computed nozzle file' do
            @nozzles.each do |nozzle|
              stub(@douchebag).nozzle_file(nozzle) { "/path/to/#{nozzle}_nozzle.rb" }
              mock(@douchebag).require("/path/to/#{nozzle}_nozzle.rb")
            end
            @douchebag.nozzles
          end

          it 'should fail if the nozzle cannot be instantiated from the computed nozzle file' do
            @nozzles.each do |nozzle|
              stub(@douchebag).nozzle_file(nozzle) { "/path/to/#{nozzle}_nozzle.rb" }
              stub(@douchebag).require("/path/to/#{nozzle}_nozzle.rb") { raise LoadError }
            end
            lambda { @douchebag.nozzles }.should raise_error
          end
          
          it 'should get the list of actual instantiated nozzle instances' do
            mock(Nozzle).nozzles
            @douchebag.nozzles
          end

          it 'should return the list of instantiated nozzle instances' do
            mock(Nozzle).nozzles { [1, 2, 3] }
            @douchebag.nozzles.should == [1, 2, 3]
          end          
        end
      end
    
      describe 'after the first time' do
        before :each do
          @path = File.expand_path(File.dirname(__FILE__) + '/../file_fixtures/nozzles/')
          stub(@douchebag).nozzle_path { @path }
          @douchebag.nozzles
        end
      
        it 'should not look up the nozzles path' do
          @douchebag.nozzles
          mock(@douchebag).nozzle_path.never
          @douchebag.nozzles
        end
        
        it 'should not get a list of nozzles from the doucheconfig' do
          mock(@doucheconfig).nozzles.never
          @douchebag.nozzles          
        end
        
        it 'should not look up nozzle file names' do
          mock(@douchebag).nozzle_file(anything).never
          @douchebag.nozzles
        end
      
        it 'should not instantiate nozzles' do
          @douchebag.nozzles
          mock(@douchebag).require.never
          @douchebag.nozzles
        end
      
        it 'should return the same list of nozzles as returned the first time' do
          result = @douchebag.nozzles
          @douchebag.nozzles.should == result
        end
      end
    end
  
    describe 'when looking up the filename from a nozzle name' do
      it 'should accept a nozzle name' do
        lambda { @douchebag.nozzle_file('shizzle') }.should_not raise_error(ArgumentError)
      end
      
      it 'should require a nozzle name' do
        lambda { @douchebag.nozzle_file }.should raise_error(ArgumentError)        
      end
      
      it 'should look up the nozzles path' do
        mock(@douchebag).nozzle_path { '/path/to/nozzles' }
        @douchebag.nozzle_file('shizzle')
      end
      
      it 'should return the complete path to the nozzle file' do
        stub(@douchebag).nozzle_path { '/path/to/nozzles' }
        @douchebag.nozzle_file('shizzle').should == '/path/to/nozzles/shizzle_nozzle.rb'
      end
    end
  
    describe 'when finding the nozzle path' do
      it 'should accept no arguments' do
        lambda { @douchebag.nozzle_path }.should_not raise_error(ArgumentError)
      end
    
      it 'should allow no arguments' do
        lambda { @douchebag.nozzle_path(:foo) }.should raise_error(ArgumentError)
      end
    
      it 'should return the path for nozzles' do
        @douchebag.nozzle_path.should == File.expand_path(File.dirname(__FILE__) + '/../lib/nozzles/')
      end
    end
  end
end
