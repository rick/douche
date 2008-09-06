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
    
    it 'should not initialize the configuration' do
      Douche.new(@options).config.should be_nil
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
    
    it 'should allow retrieving the configuration' do
      @douche.should respond_to(:config)
    end
    
    it 'should not allow setting the configuration' do
      @douche.should_not respond_to(:config=)
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
  
    describe 'when looking up nozzles' do
      before :each do
        @dir = File.expand_path(File.dirname(__FILE__) + '/../file_fixtures/simple')
        @douche = Douche.new(:directory => @dir)
        stub(Nozzle).nozzles { [] }
        stub(@douche).applicable_nozzle?(anything) { false }
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
        
        it 'should check if each file is an applicable nozzle file' do
          stub(@douche).nozzle_path { @dir }
          Find.find(@dir) {|path| mock(@douche).applicable_nozzle?(path) { false } }
          @douche.nozzles
        end
        
        describe 'when a file is an applicable nozzle' do
          it 'should instantiate the nozzle object' do
            @path = File.expand_path(File.dirname(__FILE__) + '/../file_fixtures/nozzles/')
            stub(@douche).nozzle_path { @dir }
            Find.find(@dir) do |path| 
              stub(@douche).applicable_nozzle?(path) { true }
              mock(@douche).require path 
            end
            @douche.nozzles
          end

          describe 'when a file is not an applicable nozzle' do
            it 'should not instantiate the nozzle object' do
              @path = File.expand_path(File.dirname(__FILE__) + '/../file_fixtures/nozzles/')
              stub(@douche).nozzle_path { @dir }
              Find.find(@dir) do |path| 
                stub(@douche).applicable_nozzle?(path) { false }
                mock(@douche).require(path).never
              end
              @douche.nozzles
            end
          end
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
  
    describe 'when finding the nozzle path' do
      it 'should accept no arguments' do
        lambda { @douche.nozzle_path }.should_not raise_error(ArgumentError)
      end
    
      it 'should allow no arguments' do
        lambda { @douche.nozzle_path(:foo) }.should raise_error(ArgumentError)
      end
    
      it 'should return the path for nozzles' do
        @douche.nozzle_path.should == File.expand_path(File.dirname(__FILE__) + '/../lib/nozzles/')
      end
    end
    
    describe 'when determining if a nozzle is applicable' do
      before :each do
        stub(@douche).load_configuration { { } }
        stub(@douche).nozzle_name { 'nozzle' }
        @path = '/path/to/nozzle_nozzle.rb'
      end
      
      it 'should accept a nozzle path' do
        lambda { @douche.applicable?(@path) }.should_not raise_error(ArgumentError)
      end
      
      it 'should require a nozzle path' do
        lambda { @douche.applicable? }.should raise_error(ArgumentError)
      end
      
      describe 'when called the first time' do
        it 'should pull in the configuration options' do
          mock(@douche).load_configuration { {} }
          @douche.applicable?(@path)          
        end
        
        it 'should store the configuration options' do
          @douche.applicable?(@path)
          @douche.config.should == {}
        end

        it 'should extract the nozzle name from the nozzle path' do
          mock(@douche).nozzle_name(@path) { 'nozzle' }
          @douche.applicable?(@path)
        end
        
        describe 'if the extracted nozzle name is false' do
          before :each do
            stub(@douche).nozzle_name(anything) { false }
          end
          
          it 'should return false' do
            @douche.applicable?(@path).should be_false
          end
          
          it 'should not determine if the named nozzle is active for our directory' do
            mock(@douche).active?(anything).never
            @douche.applicable?(@path).should be_false
          end
        end


        describe 'if the extracted nozzle name is set' do
          before :each do
            @name = 'shizzle'
            stub(@douche).nozzle_name(anything) { @name }
          end
          
          it 'should determine if the named nozzle is active for our directory' do
            mock(@douche).active?('shizzle') { false }
            @douche.applicable?(@path).should be_false
          end

          describe 'and the nozzle is active for our directory' do
            before :each do
              mock(@douche).active?(anything) { true }
            end
            
            it 'should consider the nozzle applicable' do
              @douche.applicable?(@path).should be_true
            end
          end

          describe 'and the nozzle is not active for our directory' do
            before :each do
              mock(@douche).active?(anything) { false }
            end
            
            it 'should consider the nozzle inapplicable' do
              @douche.applicable?(@path).should be_false              
            end
          end
        end
      end
      
      describe 'when called after the first time' do
        before :each do
          @douche.applicable?(@path)
        end
        
        it 'should not pull in the configuration options' do
          mock(@douche).load_configuration.never
          @douche.applicable?(@path)
        end
      end
    end
    
    describe 'when determining whether a Nozzle is active' do
      it 'should accept a nozzle name' do
        lambda { @douche.active?(:foo) }.should_not raise_error(ArgumentError)
      end

      it 'should require a nozzle name' do
        lambda { @douche.active? }.should raise_error(ArgumentError)
      end
      
      it 'should do some other shit (which is really based on the config file format)'
    end

    describe 'when loading the configuration' do
      before :each do
        @config_path = '/path/to/config'
        stub(@douche).config_path { @config_path }
        stub(File).read(anything) { YAML.dump({}) }        
      end
      
      it 'should work without arguments' do
        lambda { @douche.load_configuration }.should_not raise_error(ArgumentError)
      end
      
      it 'should not allow arguments' do
        lambda { @douche.load_configuration(:foo) }.should raise_error(ArgumentError)
      end
      
      it 'should ask for the configuration filename' do
        mock(@douche).config_path { @config_path }
        @douche.load_configuration
      end
      
      it 'should read the configuration file' do
        mock(File).read(@config_path) { YAML.dump({}) }
        @douche.load_configuration
      end
      
      describe 'when the configuration file can be read' do
        it 'should return an un-YAMLized version of the configuration data' do
          stub(File).read(@config_path) { YAML.dump({}) }
          @douche.load_configuration.should == {}
        end        
      end
      
      describe 'when the configuration file cannot be read' do
        it 'should fail' do
          stub(File).read(anything) { raise Errno::ENOENT }
          lambda { @douche.load_configuration }.should raise_error(Errno::ENOENT)
        end
      end
    end

    describe 'when looking up the configuration file path' do
      it 'should work without arguments' do
        lambda { @douche.config_path }.should_not raise_error(ArgumentError)
      end

      it 'should not allow arguments' do
        lambda { @douche.config_path(:foo) }.should raise_error(ArgumentError)
      end
      
      describe "when the user's home directory can be determined" do
        before :each do
          @prior_home, ENV['HOME'] = ENV['HOME'], '/Users/rick'
        end
        
        after :each do
          ENV['HOME'] = @prior_HOME
        end
        
        it "return the path to .douche.yml in the user's home directory" do
          @douche.config_path.should == File.join(ENV['HOME'], '.douche.yml')
        end        
      end
      
      describe "when the user's home directory cannot be determined" do
        before :each do
          @prior_home, ENV['HOME'] = ENV['HOME'], nil
        end
        
        after :each do
          ENV['HOME'] = @prior_HOME
        end

        it 'should fail' do
          lambda { @douche.config_path }.should raise_error(RuntimeError)
        end
      end
    end

    describe 'when extracting the nozzle name from a nozzle path' do
      it 'should accept a nozzle path' do
        lambda { @douche.nozzle_name(:foo) }.should_not raise_error(ArgumentError)
      end
      
      it 'should require a nozzle path' do
        lambda { @douche.nozzle_name }.should raise_error(ArgumentError)        
      end
      
      describe 'when the nozzle path does not end in _nozzle.rb' do 
        before :each do
          @path = '/path/to/shizzle_spizzle.rb'
        end
        
        it 'should return false' do
          @douche.nozzle_name('/foo/bar/baz.mp3').should be_false
          @douche.nozzle_name('/foo/bar/baz.rb').should be_false
          @douche.nozzle_name('baz_douche.rb').should be_false
          @douche.nozzle_name('_nozzle:rb').should be_false
          @douche.nozzle_name('_nozzle.rby').should be_false
        end
      end
      
      describe 'when the nozzle path ends in _nozzle.rb' do
        before :each do
          @path = '/path/to/shizzle_nozzle.rb'
        end
        
        it 'should return the nozzle path stripped of any path components and _nozzle.rb suffix' do
          @douche.nozzle_name(@path).should == 'shizzle'
        end
      end      
    end
  end
end
