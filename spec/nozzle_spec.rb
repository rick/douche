require File.expand_path(File.dirname(__FILE__) + '/spec_helper.rb')

require 'find'
require 'nozzle'

class NozzleA < Nozzle
end

class NozzleB < Nozzle
end

describe Nozzle do
  before :each do
    @nozzle = Nozzle.new({})
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
      it 'should accept options' do
        lambda { Nozzle.new({}) }.should_not raise_error(ArgumentError)
      end
      
      it 'should require options' do
        lambda { Nozzle.new }.should raise_error(ArgumentError)        
      end
      
      it 'should set the options to the provided options list' do
        @options = { :foo => 'bar', :baz => 'xyzzy' }
        Nozzle.new(@options).options.should == @options
      end
    end
  end

  it 'should allow querying options' do
    @nozzle.should respond_to(:options)
  end
  
  it 'should not allow setting options' do
    @nozzle.should_not respond_to(:options=)
  end
  
  it 'should allow retrieving the dry-run status' do
    @nozzle.should respond_to(:dry_run?)
  end
  
  it 'should not allow setting the dry-run status' do
    @nozzle.should_not respond_to(:dry_run=)
  end
  
  describe 'dry run?' do
    it 'should be true if initialized with :dry_run => true' do
      Nozzle.new(:dry_run => true).dry_run?.should be_true
    end

    it 'should be true if not initialized with :dry_run => true' do
      Nozzle.new({}).dry_run?.should be_false
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
      
      describe 'if dry-run mode is enabled' do
        before :each do
          stub(@nozzle).dry_run? { true }
        end
        
        it 'should not spray the file' do
          mock(@nozzle).spray(:file).times(0)
          @nozzle.douche(:file)
        end
      end
      
      describe 'if dry-run mode is disabled' do
        before :each do
          stub(@nozzle).dry_run? { false }
        end
        
        it 'should spray the file' do
          mock(@nozzle).spray(:file)
          @nozzle.douche(:file)
        end
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
  
  describe 'stank?' do
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
end

