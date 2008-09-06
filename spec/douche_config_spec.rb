require File.expand_path(File.dirname(__FILE__) + '/spec_helper.rb')

require 'yaml'
require 'douche_config'

describe DoucheConfig do
  before :each do
    @options = { :directory => '/tmp/'}
    @doucheconfig = DoucheConfig.new(@options)
  end

  describe 'when initializing' do
    it 'should accept options' do
      lambda { DoucheConfig.new(@options) }.should_not raise_error(ArgumentError)
    end
    
    it 'should require options' do
      lambda { DoucheConfig.new }.should raise_error(ArgumentError)
    end
    
    it 'should set the options to the provided options list' do
      DoucheConfig.new(@options).options.should == @options
    end
  end

  describe 'once initialized' do
    it 'should allow retrieving options' do
      @doucheconfig.should respond_to(:options)    
    end
  
    it 'should not allow setting options' do
      @doucheconfig.should_not respond_to(:options=)
    end
  
    it 'should allow retrieving the verbosity' do
      @doucheconfig.should respond_to(:verbose?)
    end
  
    it 'should not allow setting the verbosity' do
      @doucheconfig.should_not respond_to(:verbose=)
    end
    
    it 'should allow retrieving the configuration' do
      @doucheconfig.should respond_to(:config)
    end
    
    it 'should not allow setting the configuration' do
      @doucheconfig.should_not respond_to(:config=)
    end

    it 'should allow determining if a named nozzle is active' do
      @doucheconfig.should respond_to(:nozzle_is_active?)
    end
    
    describe "when determining if a named nozzle is active" do
      it 'should accept a nozzle name' do
        lambda { @doucheconfig.nozzle_is_active?('shizzle') }.should_not raise_error(ArgumentError)
      end
      
      it 'should require a nozzle name' do
        lambda { @doucheconfig.nozzle_is_active? }.should raise_error(ArgumentError)
      end
      
      it 'should do something more (see spike)'
    end

    describe 'when retrieving the verbosity' do
      it 'should be true if doucheconfig was initialized with the option :verbose => true' do
        DoucheConfig.new(@options.merge(:verbose => true)).verbose?.should be_true
      end

      it 'should be false if doucheconfig was not initialized with the option :verbose => true' do
        DoucheConfig.new(@options).verbose?.should be_false
      end
    end

    describe 'when retrieving the configuration' do
      before :each do
        @config_path = '/path/to/config'
        stub(@doucheconfig).config_path { @config_path }
        stub(File).read(anything) { YAML.dump({}) }        
      end
      
      it 'should work without arguments' do
        lambda { @doucheconfig.config }.should_not raise_error(ArgumentError)
      end
      
      it 'should not allow arguments' do
        lambda { @doucheconfig.config(:foo) }.should raise_error(ArgumentError)
      end
      
      describe 'the first time' do
        it 'should ask for the configuration filename' do
          mock(@doucheconfig).config_path { @config_path }
          @doucheconfig.config
        end
      
        it 'should read the configuration file' do
          mock(File).read(@config_path) { YAML.dump({}) }
          @doucheconfig.config
        end
      
        describe 'when the configuration file cannot be read' do
          it 'should fail' do
            stub(File).read(anything) { raise Errno::ENOENT }
            lambda { @doucheconfig.config }.should raise_error(Errno::ENOENT)
          end
        end

        describe 'when the configuration file can be read' do
          it 'should return an un-YAMLized version of the configuration data' do
            stub(File).read(@config_path) { YAML.dump({}) }
            @doucheconfig.config.should == {}
          end
        end
      end
      
      describe 'after the first time' do
        before :each do
          @results = @doucheconfig.config
        end
        
        it 'should not ask for the configuration file name' do
          mock(@doucheconfig).config_path(anything).never
          @doucheconfig.config
        end
        
        it 'should not read any files' do
          mock(File).read(anything).never
          @doucheconfig.config
        end
        
        it 'should return the same configuration data returned the first time' do
          @doucheconfig.config.should == @results          
        end
      end
    end

    describe 'when looking up the configuration file path' do
      it 'should work without arguments' do
        lambda { @doucheconfig.config_path }.should_not raise_error(ArgumentError)
      end

      it 'should not allow arguments' do
        lambda { @doucheconfig.config_path(:foo) }.should raise_error(ArgumentError)
      end
      
      describe 'when a config_file option is set' do
        before :each do
          @path = '/path/to/config_file'
          @doucheconfig = DoucheConfig.new(@options.merge(:config_file => @path))
        end
        
        it 'should return the path specified in the config_file option' do
          @doucheconfig.config_path.should == @path
        end
      end
      
      describe 'when no config_file option is set' do
        describe "when the user's home directory can be determined" do
          before :each do
            @prior_home, ENV['HOME'] = ENV['HOME'], '/Users/rick'
          end
        
          after :each do
            ENV['HOME'] = @prior_HOME
          end
        
          it "return the path to .douche.yml in the user's home directory" do
            @doucheconfig.config_path.should == File.join(ENV['HOME'], '.douche.yml')
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
            lambda { @doucheconfig.config_path }.should raise_error(RuntimeError)
          end
        end
      end
    end
  end
end
