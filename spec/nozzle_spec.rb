require File.expand_path(File.dirname(__FILE__) + '/spec_helper.rb')

require 'find'
require 'nozzle'
require 'gynecologist'

class NozzleA < Nozzle
end

class NozzleB < Nozzle
end

describe Nozzle do
  before :each do
    @config = {}
    @options = { :foo => 'bar', :baz => 'xyzzy' }
    stub(@config).options { @options }
    @nozzle = Nozzle.new(@config)
  end
  
  describe 'as a class' do
    it 'should be able to generate the known Nozzle list' do
      Nozzle.should respond_to(:nozzles)
    end
    
    describe 'when generating the known Nozzle list' do
      it 'should work without arguments' do
        lambda { Nozzle.nozzles }.should_not raise_error(ArgumentError)
      end
      
      it 'should not accept any arguments' do
        lambda { Nozzle.nozzles(:foo) }.should raise_error(ArgumentError)
      end

      it 'should find all classes' do
        mock(ObjectSpace).each_object(Class) { [] }
        Nozzle.nozzles
      end
      
      it 'should return the list of subclasses of Nozzle' do
        result = Nozzle.nozzles
        [ NozzleA, NozzleB ].each {|klass| result.should include(klass)}
      end
      
      it 'should not include Nozzle in the returned class list' do
        Nozzle.nozzles.should_not include(Nozzle)
      end
    end
    
    describe 'when initializing' do
      it 'should accept a DoucheConfig object' do
        lambda { Nozzle.new({}) }.should_not raise_error(ArgumentError)
      end
      
      it 'should require a DoucheConfig object' do
        lambda { Nozzle.new }.should raise_error(ArgumentError)        
      end
      
      it 'should save the DoucheConfig object' do
        Nozzle.new(@config).config.should == @config
      end
      
      it 'should query the DoucheConfig object for options' do
        mock(@config).options { {} }
        Nozzle.new(@config)
      end
      
      it 'should set the options to the DoucheConfig options list' do
        Nozzle.new(@config).options.should == @options
      end
      
      it 'should set the directory option' do
        @options.merge!(:directory => 'foo')
        Nozzle.new(@config).directory.should == 'foo'
      end
    end
  end

  describe 'once initialized' do
    it 'should allow querying options' do
      @nozzle.should respond_to(:options)
    end
  
    it 'should not allow setting options' do
      @nozzle.should_not respond_to(:options=)
    end
  
    it 'should allow querying the directory setting' do
      @nozzle.should respond_to(:directory)
    end
  
    it 'should not allow setting the directory setting' do
      @nozzle.should_not respond_to(:directory=)
    end
    
    it 'should allow querying the config object' do
      @nozzle.should respond_to(:config)
    end
    
    it 'should not allow setting the config object' do
      @nozzle.should_not respond_to(:config=)
    end
    
    it 'should allow querying its parameters' do
      @nozzle.should respond_to(:params)
    end
    
    it 'should not allow setting its parameters' do
      @nozzle.should_not respond_to(:params=)
    end
    
    describe 'when querying its parameters' do
      before :each do
        stub(@nozzle).config { @config }
        stub(@config).nozzle_parameters { {} }
      end
      
      it 'should work without arguments' do
        lambda { @nozzle.params }.should_not raise_error(ArgumentError)
      end
      
      it 'should not allow arguments' do
        lambda { @nozzle.params(:foo) }.should raise_error(ArgumentError)
      end
      
      describe 'the first time' do
        before :each do
          stub(@nozzle).name { 'shizzle' }
        end
        
        it 'should look up its own name' do
          mock(@nozzle).name
          @nozzle.params
        end
      
        it 'should ask the config object for its parameters, using its name' do
          mock(@nozzle.config).nozzle_parameters('shizzle')
          @nozzle.params
        end
        
        it 'should return the parameters from the config object' do
          @params = { :foo => :bar }
          mock(@nozzle.config).nozzle_parameters('shizzle') { @params }
          @nozzle.params.should == @params
        end
      end
      
      describe 'after the first time' do
        before :each do
          @results = @nozzle.params
        end
        
        it 'should not look up its name' do
          mock(@nozzle).name.never
          @nozzle.params
        end
        
        it 'should not ask the config object for parameters' do
          mock(@config).nozzle_parameters(anything).never
        end
        
        it 'should return the same parameters returned the first time' do
          @nozzle.params.should == @results
        end
      end
    end
    
    it 'should allow looking up the name' do
      @nozzle.should respond_to(:name)
    end
    
    it 'should not allow setting the name' do
      @nozzle.should_not respond_to(:name=)
    end
    
    describe 'when looking up the name' do
      it 'should work without arguments' do
        lambda { @nozzle.name }.should_not raise_error(ArgumentError)
      end
      
      it 'should not accept arguments' do
        lambda { @nozzle.name(:foo) }.should raise_error(ArgumentError)
      end
      
      it "should return the nozzle name, extracted from the nozzle's filename" do
        stub(@nozzle).filename { File.join(File.dirname(__FILE__), '/shizzle_nozzle.rb') }
        @nozzle.name.should == 'shizzle'
      end
    end
  
    it 'should allow retrieving the dry-run status' do
      @nozzle.should respond_to(:dry_run?)
    end
  
    it 'should not allow setting the dry-run status' do
      @nozzle.should_not respond_to(:dry_run=)
    end
  
    describe 'when retrieving the dry-run status' do
      it 'should be true if nozzle was initialized with the option :dry_run => true' do
        @options.merge!(:dry_run => true)
        Nozzle.new(@config).dry_run?.should be_true
      end

      it 'should be false if nozzle was not initialized with the option :dry_run => true' do
        Nozzle.new(@config).dry_run?.should be_false
      end
    end
  
    it 'should allow retrieving the verbosity' do
      @nozzle.should respond_to(:verbose?)
    end
  
    it 'should not allow setting the verbosity' do
      @nozzle.should_not respond_to(:verbose=)
    end
  
    describe 'when retrieving the verbosity' do
      it 'should be true if nozzle was initialized with the option :verbose => true' do
        @options.merge!(:verbose => true)
        Nozzle.new(@config).verbose?.should be_true
      end

      it 'should be false if nozzle was not initialized with the option :verbose => true' do
        Nozzle.new(@config).verbose?.should be_false
      end
    end
  
    it 'should be able to douche a file' do
      @nozzle.should respond_to(:douche)
    end
  
    describe 'when douching a file' do
      it 'should accept a file argument' do
        lambda { @nozzle.douche(:file) }.should_not raise_error(ArgumentError)
      end
    
      it 'should require a file argument' do
        lambda { @nozzle.douche }.should raise_error(ArgumentError)
      end
    
      it 'should determine if the file needs douching' do
        mock(@nozzle).stank?(:file)
        @nozzle.douche(:file)
      end
    
      describe 'when the file needs douching' do
        before :each do
          stub(@nozzle).stank?(:file) { true }
        end

        describe 'if verbose mode is enabled' do
          before :each do
            stub(@nozzle).verbose? { true }
          end

          it 'should display a message about processing the file' do
            mock(@nozzle).puts(anything)
            @nozzle.douche(:file)
          end
        end

        describe 'if verbose mode is disabled' do
          before :each do
            stub(@nozzle).verbose? { false }
          end

          it 'should not display a message about processing the file' do
            mock(@nozzle).puts(anything).times(0)
            @nozzle.douche(:file)
          end
        end

        it 'should spray the file' do
          mock(@nozzle).spray(:file)
          @nozzle.douche(:file)
        end
      end
    
      describe 'when the file does not need douching' do
        before :each do
          stub(@nozzle).stank?(:file) { false }
        end
      
        it 'should not spray the file' do
          mock(@nozzle).spray(:file).times(0)
          @nozzle.douche(:file)
        end
      end
    end
  
    describe 'when checking if a file is stank' do
      it 'should accept a file' do
        lambda { @nozzle.stank?(:file) }.should_not raise_error(ArgumentError)
      end
    
      it 'should require a file' do
        lambda { @nozzle.stank? }.should raise_error(ArgumentError)
      end
    
      it 'should return false' do
        @nozzle.stank?(:file).should_not be_true
      end
    end
  
    describe 'when spraying a file' do
      it 'should accept a file' do
        lambda { @nozzle.spray(:file) }.should_not raise_error(ArgumentError)
      end
    
      it 'should require a file' do
        lambda { @nozzle.spray }.should raise_error(ArgumentError)
      end
    end
    
    it 'should allow querying file statuses' do
      @nozzle.should respond_to(:status)
    end

    describe 'when querying file statuses' do
      before :each do
        @gynecologist = Gynecologist.new(@options)
      end
      
      it 'should work without arguments' do
        lambda { @nozzle.status }.should_not raise_error(ArgumentError)
      end
      
      it 'should allow no arguments' do
        lambda { @nozzle.status(:foo) }.should raise_error(ArgumentError)
      end
      
      describe 'the first time' do
        it 'should instantiate a new status object' do
          mock(Gynecologist).new(anything) { @gynecologist }
          @nozzle.status
        end
        
        it 'should provide the options list to the new status object' do
          mock(Gynecologist).new(@options) { @gynecologist }
          @nozzle.status
        end
        
        it 'should return the instantiated status object' do
          stub(Gynecologist).new(@options) { @gynecologist }
          @nozzle.status.should == @gynecologist
        end
      end

      describe 'after the first time' do
        before :each do
          @result = @nozzle.status
        end
        
        it 'should not instantiate a new status object' do
          mock(Gynecologist).new(anything).never
          @nozzle.status
        end

        it 'should return the same status object returned the first time' do
          @nozzle.status.should == @result
        end
      end
    end
    
    it 'should allow determining if a file has been douched' do
      @nozzle.should respond_to(:douched?)
    end

    describe 'when determining if a file has been douched' do
      before :each do
        @file = '/path/to/file'
        @status = { }
        @name = 'shizzle'
        stub(@nozzle).status { @status }
        stub(@nozzle).name { @name }
      end
      
      it 'should accept a file argument' do
        lambda { @nozzle.douched?(@file) }.should_not raise_error(ArgumentError)
      end
      
      it 'should require a file argument' do
        lambda { @nozzle.douched? }.should raise_error(ArgumentError)
      end

      it 'should ask the status object if this nozzle has seen the file' do
        mock(@status).douched?(@name, @file) { false }
        @nozzle.douched?(@file)
      end
 
      it 'should return true if the status object says this nozzle has seen the file' do
        stub(@status).douched?(@name, @file) { true }
        @nozzle.douched?(@file).should be_true
      end
      
      it 'should return false if the status object says this nozzle has not seen the file' do
        stub(@status).douched?(@name, @file) { false }
        @nozzle.douched?(@file).should be_false        
      end
    end

    it 'should allow extracting the relative path for a file' do
      @nozzle.should respond_to(:relative_path)
    end

    describe 'when extracting the relative path for a file' do
      before :each do
        @file = '/path/to/artist/album/filename'
      end
      
      it 'should accept a filename' do
        lambda { @nozzle.relative_path(@file) }.should_not raise_error(ArgumentError)
      end
      
      it 'should require a filename' do
        lambda { @nozzle.relative_path }.should raise_error(ArgumentError)
      end
      
      it 'should return the directory path, relative to the configured directory, of the file' do
        stub(@nozzle).directory { '/path/to' }
        @nozzle.relative_path(@file).should == '/artist/album'
      end
    end
    
    it 'should allow marking a file as douched' do
      @nozzle.should respond_to(:douched)
    end

    describe 'when marking a file as douched' do
      before :each do
        @file = '/path/to/filename'
        @name = 'shizzle'
        stub(@nozzle).name { @name }
        @status = { }
        stub(@nozzle).status { @status }
      end
      
      it 'should accept a filename' do
        lambda { @nozzle.douched(@file) }.should_not raise_error(ArgumentError)
      end
      
      it 'should require a filename' do
        lambda { @nozzle.douched }.should raise_error(ArgumentError)
      end
      
      it 'should tell the status object to mark the file as douched by this nozzle' do
        mock(@status).douched(@name, @file)
        @nozzle.douched(@file)
      end
      
      it 'should return true if marking the file as douched was successful' do
        stub(@status).douched(@name, @file) { true }
        @nozzle.douched(@file).should be_true
      end
      
      it 'should return false if marking the file as douched was not successful' do
        stub(@status).douched(@name, @file) { false }
        @nozzle.douched(@file).should be_false
      end
    end

    it 'should allow copying a file' do
      @nozzle.should respond_to(:copy)
    end

    describe 'when copying a file' do
      it 'should accept source and destination filenames'
      it 'should return false if the source file cannot be found'
      it 'should require source and destination filenames'
      it 'should create any missing destination directories'
      it 'should return false if creating missing directories fails'
      it 'should copy the source file to the destination file'
      it 'should return false if the copy fails'
      it 'should return true if the copy is successful'
    end
  end
end
