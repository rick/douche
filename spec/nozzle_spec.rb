require File.expand_path(File.dirname(__FILE__) + '/spec_helper.rb')

require 'find'
require 'nozzle'

class NozzleA < Nozzle
end

class NozzleB < Nozzle
end

describe Nozzle do
  before :each do
    @nozzle = Nozzle.new
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
  end

  # TODO: options
  
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
      mock(@nozzle).dirty?(:file)
      @nozzle.douche(:file)
    end
    
    describe 'when the file needs douching' do
      before :each do
        stub(@nozzle).dirty?(:file) { true }
      end
      
      it 'should spray the file' do
        mock(@nozzle).spray(:file)
        @nozzle.douche(:file)
      end
    end
    
    describe 'when the file does not need douching' do
      before :each do
        stub(@nozzle).dirty?(:file) { false }
      end
      
      it 'should not spray the file' do
        mock(@nozzle).spray(:file).times(0)
        @nozzle.douche(:file)
      end
    end
  end
end

