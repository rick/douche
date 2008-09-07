require File.expand_path(File.dirname(__FILE__) + '/spec_helper.rb')

require 'yaml'
require 'douche_config'

describe DoucheConfig do
  before :each do
    @dir = '/tmp'
    @options = { :directory => @dir }
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
        stub(@doucheconfig).normalize(anything) { { } }
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
          before :each do
            stub(File).read(@config_path) { YAML.dump({}) }            
          end
          
          it 'should normalize an un-YAMLized version of the configuration data' do
            mock(@doucheconfig).normalize({})
            @doucheconfig.config
          end
          
          it 'should return the normalized data' do
            stub(@doucheconfig).normalize(anything) { :foo }
            @doucheconfig.config.should == :foo
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
    
    it 'should allow normalizing the unYAML-ized configuration data' do
      @doucheconfig.should respond_to(:normalize)
    end
    
    describe 'normalizing unYAML-ized configuration data' do
      it 'should accept the unYAML-ized configuration data' do
        lambda { @doucheconfig.normalize(:foo) }.should_not raise_error(ArgumentError)
      end
      
      it 'should require the unYAML-ized configuration data' do
        lambda { @doucheconfig.normalize }.should raise_error(ArgumentError)
      end
      
      it 'should fail if the data is not a hash' do
        lambda { @doucheconfig.normalize([]) }.should raise_error
      end
      
      it 'should convert any array nozzles under a path to a hash of nozzles with nozzle names as keys' do
        @doucheconfig.normalize({ "/path/to" => [ "foo", "bar"], "/path/from" => [{ "baz" => { } }, { "xyzzy" => {} } ] }).should ==
        { "/path/to" => [ { "foo" => {} }, { "bar" => {} } ], "/path/from" => [{ "baz" => { } }, { "xyzzy" => {} } ] }
      end
    end
    
    it 'should allow fetching a series of active nozzle names' do
      @doucheconfig.should respond_to(:nozzles)
    end
    
    describe 'when fetching a series of active nozzles names' do
      before :each do
        @path = '/path/to/mp3z'
        stub(@doucheconfig).active_paths { [ @path ] }
        stub(@doucheconfig).config { { @path => [ {"foo" => {} }, { "bar" => {} } ] } }
      end
      
      it 'should work without arguments' do
        lambda { @doucheconfig.nozzles }.should_not raise_error(ArgumentError)
      end
      
      it 'should not allow arguments' do
        lambda { @doucheconfig.nozzles(:foo) }.should raise_error(ArgumentError)        
      end
      
      it 'should retrieve the active paths from the config' do
        mock(@doucheconfig).active_paths { [ @path ] }
        @doucheconfig.nozzles
      end
      
      it 'should return an empty list if there is no active path' do
        stub(@doucheconfig).active_paths { [] }
        @doucheconfig.nozzles.should == []
      end
      
      it 'should fail if there is more than one active path' do
        stub(@doucheconfig).active_paths { [ @path, @path.succ ] }
        lambda { @doucheconfig.nozzles }.should raise_error(RuntimeError)        
      end
      
      it 'should return the list of nozzles for the active path' do
        @doucheconfig.nozzles.sort.should == [ "bar", "foo" ]
      end
    end

    it 'should allow fetching parameters for a nozzle' do
      @doucheconfig.should respond_to(:nozzle_parameters)
    end
    
    describe 'when fetching parameters for a nozzle' do
      before :each do
        @name = 'shizzle'
        @path = '/foo/bar'
        @paths = [ @path ]
        stub(@doucheconfig).active_paths { @paths }
        stub(@doucheconfig).config { { @path => [ { @name => { 'baz' => 'xyzzy' } } ] } }
      end
      
      it 'should accept a nozzle name' do
        lambda { @doucheconfig.nozzle_parameters(@name) }.should_not raise_error(ArgumentError)
      end
      
      it 'should require a nozzle name' do
        lambda { @doucheconfig.nozzle_parameters }.should raise_error(ArgumentError)
      end
      
      it 'should fetch the active paths from the configuration' do
        mock(@doucheconfig).active_paths { @paths }
        @doucheconfig.nozzle_parameters(@name)
      end
      
      describe 'when there is no matching nozzle in the first active path' do
        it 'should fail' do
          stub(@doucheconfig).config { { @path => [ ] } }
          lambda { @doucheconfig.nozzle_parameters(@name) }.should raise_error
        end
      end
      
      describe 'when there is a matching nozzle in the first active path' do
        it 'should return the parameters for the matching nozzle' do
          @doucheconfig.nozzle_parameters(@name).should == { 'baz' => 'xyzzy' }
        end
      end
    end
    
    it 'should allow finding the active paths from the config' do
      @doucheconfig.should respond_to(:active_paths)
    end
    
    describe 'when finding the active paths from the config' do
      before :each do
        @config = { "/foo/bar" => [], "/bar/baz" => [], "/baz/xyzzy" => [] }
        stub(@doucheconfig).config { @config }
        stub(@doucheconfig).active_path? { false }
      end
      
      it 'should work without arguments' do
        lambda { @doucheconfig.active_paths }.should_not raise_error(ArgumentError)
      end
      
      it 'should not accept an argument' do
        lambda { @doucheconfig.active_paths(:foo) }.should raise_error(ArgumentError)        
      end
      
      describe 'the first time' do
        it 'should return the empty list if no paths are found' do
          stub(@doucheconfig).config { {} }
          @doucheconfig.active_paths.should == []
        end
      
        it 'should check if each path in the config is active' do
          @config.keys.each do |path|
            mock(@doucheconfig).active_path?(path) { false }
          end
          @doucheconfig.active_paths
        end
      
        it 'return the paths which are found to be active' do
          stub(@doucheconfig).active_path?("/foo/bar") { true }
          stub(@doucheconfig).active_path?("/bar/baz") { false }
          stub(@doucheconfig).active_path?("/baz/xyzzy") { true }
          @doucheconfig.active_paths.sort.should == ["/baz/xyzzy", "/foo/bar"]
        end
      end
      
      describe 'after the first time' do
        before :each do
          @results = @doucheconfig.active_paths
        end
        
        it 'should not look up paths' do
          mock(@config).keys.never
          @doucheconfig.active_paths
        end
        
        it 'should not check paths for activity' do
          mock(@doucheconfig).active_path?(anything).never          
          @doucheconfig.active_paths
        end
        
        it 'should return the same paths as were returned the first time' do
          @doucheconfig.active_paths.should == @results
        end
      end
    end
    
    it 'should have a means of determining if a single path is active' do
      @doucheconfig.should respond_to(:active_path?)
    end
    
    describe 'when determining if a single path is active' do
      before :each do
        @path = "/path/to/foo"
        stub(@doucheconfig).contains?(anything, anything) { false }
      end
      
      it 'should accept a path' do
        lambda { @doucheconfig.active_path?(@path) }.should_not raise_error(ArgumentError)
      end
      
      it 'should require a path' do
        lambda { @doucheconfig.active_path? }.should raise_error(ArgumentError)        
      end
      
      it 'should retrieve the directory path' do
        mock(@doucheconfig).directory { @dir }
        @doucheconfig.active_path?(@path)
      end

      it 'should see if the directory path contains the provided path' do
        mock(@doucheconfig).contains?(@dir, @path)
        @doucheconfig.active_path?(@path)
      end
      
      it 'should return the result of checking containment' do
        stub(@doucheconfig).contains?(@dir, @path) { :foo }
        @doucheconfig.active_path?(@path).should == :foo        
      end
    end
    
    it 'should be able to test containment of one directory inside another' do
      @doucheconfig.should respond_to(:contains?)
    end
    
    describe "when testing containment of one directory inside another" do
      it "should accept two directories (container, containee)" do
        lambda { @doucheconfig.contains?(:container, :containee) }.should_not raise_error(ArgumentError)
      end
      
      it "should require two directories" do
        lambda { @doucheconfig.contains?(:container) }.should raise_error(ArgumentError)        
      end
      
      it 'should consider identical paths as containing' do
        @doucheconfig.contains?('/path/to/foo', '/path/to/foo').should be_true
      end
      
      it 'should not be fooled by relative path elements (/../)' do
        @doucheconfig.contains?('/path/to/foo', '/path/to/../to/foo').should be_true        
        @doucheconfig.contains?('/path/to/../to/../to/foo', '/path/to/../to/foo').should be_true        
      end
      
      it 'should not consider independent paths to be containing' do
        @doucheconfig.contains?('/path/to/foo', '/tmp/bar').should be_false     
      end
      
      it 'should consider containing paths to be containing' do
        @doucheconfig.contains?('/path/', '/path/to/foo').should be_true
        @doucheconfig.contains?('/path', '/path/to/').should be_true
        @doucheconfig.contains?('/path/to/foo/bar', '/path/to/foo/bar/baz').should be_true
        @doucheconfig.contains?('/path/to', '/path/to/foo/bar/baz/xyzzy').should be_true
      end

      it 'should consider non-containing paths to not be containing' do
        @doucheconfig.contains?('/path/to/foo', '/path/').should be_false
        @doucheconfig.contains?('/path/to/', '/path').should be_false
        @doucheconfig.contains?('/path/to/foo/bar/baz', '/path/to/foo/bar').should be_false
        @doucheconfig.contains?('/path/to/foo/bar/baz/xyzzy', '/path/to').should be_false
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
