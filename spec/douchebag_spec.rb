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
        @dir = File.expand_path(File.dirname(__FILE__) + '/../file_fixtures/simple')
        @douchebag = Douchebag.new(:directory => @dir)
        stub(Nozzle).nozzles { [] }
        stub(@douchebag).applicable?(anything) { false }
      end
    
      it 'should accept no arguments' do
        lambda { @douchebag.nozzles }.should_not raise_error(ArgumentError)
      end
    
      it 'should not allow any arguments' do
        lambda { @douchebag.nozzles(:foo) }.should raise_error(ArgumentError)
      end
    
      describe 'the first time' do
        it 'should look up the nozzles path' do
          mock(@douchebag).nozzle_path { '/path/to/nozzles' }
          stub(Find).find('/path/to/nozzles') { [] }
          @douchebag.nozzles
        end
    
        it 'should find all nozzles in the nozzles path' do
          stub(@douchebag).nozzle_path { '/path/to/nozzles' }
          mock(Find).find('/path/to/nozzles') { [] }
          @douchebag.nozzles
        end
        
        it 'should check if each file is an applicable nozzle file' do
          stub(@douchebag).nozzle_path { @dir }
          Find.find(@dir) {|path| mock(@douchebag).applicable?(path) { false } }
          @douchebag.nozzles
        end
        
        describe 'when a file is an applicable nozzle' do
          it 'should instantiate the nozzle object' do
            @path = File.expand_path(File.dirname(__FILE__) + '/../file_fixtures/nozzles/')
            stub(@douchebag).nozzle_path { @dir }
            Find.find(@dir) do |path| 
              stub(@douchebag).applicable?(path) { true }
              mock(@douchebag).require path 
            end
            @douchebag.nozzles
          end

          describe 'when a file is not an applicable nozzle' do
            it 'should not instantiate the nozzle object' do
              @path = File.expand_path(File.dirname(__FILE__) + '/../file_fixtures/nozzles/')
              stub(@douchebag).nozzle_path { @dir }
              Find.find(@dir) do |path| 
                stub(@douchebag).applicable?(path) { false }
                mock(@douchebag).require(path).never
              end
              @douchebag.nozzles
            end
          end
        end
      
        it 'should return the final list of nozzles' do
          stub(Nozzle).nozzles { [ 1, 2, 3 ] }
          @douchebag.nozzles.should == [ 1, 2, 3 ]
        end
      end
    
      describe 'after the first time' do
        before :each do
          @path = File.expand_path(File.dirname(__FILE__) + '/../file_fixtures/nozzles/')
          stub(@douchebag).nozzle_path { @path }
        end
      
        it 'should not look up the nozzles path' do
          @douchebag.nozzles
          mock(@douchebag).nozzle_path.times(0)
          @douchebag.nozzles
        end
      
        it 'should not find nozzles' do
          @douchebag.nozzles
          mock(Find).find.times(0)
          @douchebag.nozzles
        end
      
        it 'should not instantiate nozzles' do
          @douchebag.nozzles
          mock(@douchebag).require.times(0)
          @douchebag.nozzles
        end
      
        it 'should return the same list of nozzles as returned the first time' do
          result = @douchebag.nozzles
          @douchebag.nozzles.should == result
        end
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
    
    describe 'when determining if a nozzle is applicable' do
      before :each do
        stub(DoucheConfig).new(@options) { {} }
        stub(@douchebag).nozzle_name { 'nozzle' }
        @path = '/path/to/nozzle_nozzle.rb'
      end
      
      it 'should accept a nozzle path' do
        lambda { @douchebag.applicable?(@path) }.should_not raise_error(ArgumentError)
      end
      
      it 'should require a nozzle path' do
        lambda { @douchebag.applicable? }.should raise_error(ArgumentError)
      end
      
      describe 'when called the first time' do
        it 'should extract the nozzle name from the nozzle path' do
          mock(@douchebag).nozzle_name(@path) { 'nozzle' }
          @douchebag.applicable?(@path)
        end
        
        describe 'if the extracted nozzle name is false' do
          before :each do
            stub(@douchebag).nozzle_name(anything) { false }
          end
          
          it 'should return false' do
            @douchebag.applicable?(@path).should be_false
          end
          
          it 'should not determine if the named nozzle is active for our directory' do
            mock(@douchebag).active?(anything).never
            @douchebag.applicable?(@path).should be_false
          end
        end

        describe 'if the extracted nozzle name is set' do
          before :each do
            @name = 'shizzle'
            stub(@douchebag).nozzle_name(anything) { @name }
          end
          
          it 'should determine if the named nozzle is active for our directory' do
            mock(@douchebag).active?('shizzle') { false }
            @douchebag.applicable?(@path).should be_false
          end

          describe 'and the nozzle is active for our directory' do
            before :each do
              mock(@douchebag).active?(anything) { true }
            end
            
            it 'should consider the nozzle applicable' do
              @douchebag.applicable?(@path).should be_true
            end
          end

          describe 'and the nozzle is not active for our directory' do
            before :each do
              mock(@douchebag).active?(anything) { false }
            end
            
            it 'should consider the nozzle inapplicable' do
              @douchebag.applicable?(@path).should be_false              
            end
          end
        end
      end
      
      describe 'when called after the first time' do
        before :each do
          @douchebag.applicable?(@path)
        end
        
        it 'should not pull in the configuration options' do
          mock(@douchebag).load_configuration.never
          @douchebag.applicable?(@path)
        end
      end
    end
    
    describe 'when determining whether a Nozzle is active' do
      it 'should accept a nozzle name' do
        lambda { @douchebag.active?(:foo) }.should_not raise_error(ArgumentError)
      end

      it 'should require a nozzle name' do
        lambda { @douchebag.active? }.should raise_error(ArgumentError)
      end
      
      it 'should do some other shit (which is really interaction with DoucheConfig)'
    end

    describe 'when extracting the nozzle name from a nozzle path' do
      it 'should accept a nozzle path' do
        lambda { @douchebag.nozzle_name(:foo) }.should_not raise_error(ArgumentError)
      end
      
      it 'should require a nozzle path' do
        lambda { @douchebag.nozzle_name }.should raise_error(ArgumentError)        
      end
      
      describe 'when the nozzle path does not end in _nozzle.rb' do 
        before :each do
          @path = '/path/to/shizzle_spizzle.rb'
        end
        
        it 'should return false' do
          @douchebag.nozzle_name('/foo/bar/baz.mp3').should be_false
          @douchebag.nozzle_name('/foo/bar/baz.rb').should be_false
          @douchebag.nozzle_name('baz_douche.rb').should be_false
          @douchebag.nozzle_name('_nozzle:rb').should be_false
          @douchebag.nozzle_name('_nozzle.rby').should be_false
        end
      end
      
      describe 'when the nozzle path ends in _nozzle.rb' do
        before :each do
          @path = '/path/to/shizzle_nozzle.rb'
        end
        
        it 'should return the nozzle path stripped of any path components and _nozzle.rb suffix' do
          @douchebag.nozzle_name(@path).should == 'shizzle'
        end
      end      
    end
  end
end
