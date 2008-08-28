require File.expand_path(File.dirname(__FILE__) + '/spec_helper.rb')

require 'douche'

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
    
    it 'should set the directory option to the provided value' do |variable|
      Douche.new(@options).directory.should == @options[:directory]
    end
  end
  
  it 'should allow retrieving the directory' do
    @douche.should respond_to(:directory)
  end
  
  it 'should not allow setting the directory' do
    @douche.should_not respond_to(:directory=)
  end
end
