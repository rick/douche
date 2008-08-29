require File.expand_path(File.dirname(__FILE__) + '/spec_helper.rb')

require 'find'
require 'nozzle'

class NozzleA < Nozzle
end

class NozzleB < Nozzle
end

describe Nozzle do
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
end

