require File.expand_path(File.dirname(__FILE__) + '/spec_helper.rb')

require 'gynecologist'
require 'yaml'

describe Gynecologist do
  before :each do
    @options = { :foo => 'bar', :baz => 'xyzzy' }
    @gyno = Gynecologist.new(@options)
  end
  
  describe 'when initializing' do
    it 'should accept a set of options' do
      lambda { Gynecologist.new({}) }.should_not raise_error(ArgumentError)
    end
    
    it 'should require a set of options' do
      lambda { Gynecologist.new }.should raise_error(ArgumentError)        
    end
    
    it 'should save the options' do
      Gynecologist.new(@options).options.should == @options
    end
    
    it 'should set the directory option' do
      @options.merge!(:directory => 'foo')
      Gynecologist.new(@options).directory.should == 'foo'
    end
  end

  describe 'once initialized' do
    it 'should allow querying options' do
      @gyno.should respond_to(:options)
    end
  
    it 'should not allow setting options' do
      @gyno.should_not respond_to(:options=)
    end
  
    it 'should allow querying the directory setting' do
      @gyno.should respond_to(:directory)
    end
  
    it 'should not allow setting the directory setting' do
      @gyno.should_not respond_to(:directory=)
    end  
  end
  
  it "should allow locating a gyno's status file" do
    @gyno.should respond_to(:status_file)
  end
  
  describe "when locating a nozzle's status file" do
    before :each do
      @directory = '/the/main/path'
      stub(@gyno).directory { @directory }
    end
    
    it 'should accept a nozzle name' do
      lambda { @gyno.status_file(@name) }.should_not raise_error(ArgumentError)
    end
    
    it 'should require a nozzle name' do
      lambda { @gyno.status_file }.should raise_error(ArgumentError)
    end
    
    it "should return a gyno-named filename in the main configured directory" do
      @gyno.status_file('shizzle').should == '/the/main/path/.douche_shizzle'
    end
  end
  
  it 'should allow locating the enclosing directory for a file' do
    @gyno.should respond_to(:enclosing_directory)
  end

  describe 'when locating the enclosing directory for a file' do
    it 'should accept a file argument' do
      lambda { @gyno.enclosing_directory(:foo) }.should_not raise_error(ArgumentError)
    end
    
    it 'should require a file argument' do
      lambda { @gyno.enclosing_directory }.should raise_error(ArgumentError)
    end
    
    it 'should return the enclosing directory for the file' do
      @gyno.enclosing_directory('/path/to/file').should == '/path/to'
    end
  end

  it 'should allow checking whether a file has been douched by a nozzle' do
    @gyno.should respond_to(:douched?)
  end

  describe 'when checking whether a file has been douched by a nozzle' do
    before :each do
      @name = 'shizzle'
      @file = '/path/to/file'
    end
    
    it 'should accept a nozzle name and a file path' do
      lambda { @gyno.douched?(@name, @file) }.should_not raise_error(ArgumentError)
    end
    
    it 'should require a nozzle name and a file path' do
      lambda { @gyno.douched?(@name) }.should raise_error(ArgumentError)
    end
    
    it 'should pull the douched statuses for the nozzle' do
      mock(@gyno).douched_statuses(@name) { { } }
      @gyno.douched?(@name, @file)
    end
    
    it 'should return true if the file is in the nozzle douched statuses' do
      stub(@gyno).douched_statuses(@name) { { @file => true } }
      @gyno.douched?(@name, @file).should be_true
    end

    it 'should return false if the file is not in the nozzle douched statuses' do
      stub(@gyno).douched_statuses(@name) { { } }
      @gyno.douched?(@name, @file).should be_false     
    end
  end

  it 'should allow retrieving douched statuses for a nozzle' do
    @gyno.should respond_to(:douched_statuses)
  end

  describe 'when retrieving douched statuses for a nozzle' do
    before :each do
      @name = 'shizzle'
      @file = '/path/to/nozzle_file'
      stub(@gyno).name { @name }
      stub(@gyno).status_file(@name) { @file }
      stub(File).read(@file) { YAML.dump({}) }
    end
    
    it 'should accept a nozzle name' do
      lambda { @gyno.douched_statuses(@name) }.should_not raise_error(ArgumentError)
    end

    it 'should require a nozzle name' do
      lambda { @gyno.douched_statuses }.should raise_error(ArgumentError)
    end

    it 'should look up the nozzle status file' do
      mock(@gyno).status_file(@name) { @file }
      @gyno.douched_statuses(@name)
    end

    it 'should read the contents of the nozzle status file' do
      mock(File).read(@file) { YAML.dump({}) }
      @gyno.douched_statuses(@name)
    end

    describe 'if the nozzle status file cannot be read' do
      before :each do
        stub(File).read(@file) { raise Errno::ENOENT }
      end
      
      it 'should return an empty hash' do
        @gyno.douched_statuses(@name).should == { }
      end      
    end

    describe 'if the nozzle status file can be read' do
      before :each do
        @contents = { :foo => 'bar'  }
        stub(File).read(@file) { YAML.dump(@contents) }
      end
      
      it 'should return the un-yaml-ized contents of the file' do
        @gyno.douched_statuses(@name).should == @contents
      end
    end

    it 'should allow marking a file as douched by a nozzle' do
      @gyno.should respond_to(:douched)
    end

    describe 'when marking a file as douched by a nozzle' do
      before :each do
        @name = 'shizzle'
        @hash = { :foo => 'bar' }
        @file = '/path/to/filename'
        stub(@gyno).save_douched_statuses(anything, anything)
        stub(@gyno).douched_statuses(@name) { @hash }
      end
      
      it 'should accept a nozzle name and filename' do
        lambda { @gyno.douched(@name, @file) }.should_not raise_error(ArgumentError)
      end
      
      it 'should require a nozzle and and filename' do
        lambda { @gyno.douched(@name) }.should raise_error(ArgumentError)
      end
      
      it 'should fetch the douched statuses for the nozzle' do
        mock(@gyno).douched_statuses(@name) { @hash }
        @gyno.douched(@name, @file)
      end
      
      it 'should save douched statuses for the nozzle' do
        mock(@gyno).save_douched_statuses(@name, anything)
        @gyno.douched(@name, @file)
      end
      
      it 'should include the filename in the saved douched statuses for the nozzle' do
        mock(@gyno).save_douched_statuses(@name, @hash.merge(@file => true))
        @gyno.douched(@name, @file)
      end
    end

    it 'should allow saving douched statuses for a nozzle' do
      @gyno.should respond_to(:save_douched_statuses)
    end

    describe 'when saving douched statuses for a nozzle' do
      before :each do
        @name = 'shizzle'
        @hash = { }
        @file = '/path/to/.douche_shizzle'
        stub(@gyno).status_file(@name) { @file }
        stub(@gyno).file_create(@file, anything) { true }
      end
      
      it 'should accept a nozzle name and a statuses hash' do
        lambda { @gyno.save_douched_statuses(@name, @hash)}.should_not raise_error(ArgumentError)
      end
      
      it 'should require a nozzle name and a statuses hash' do
        lambda { @gyno.save_douched_statuses(@name) }.should raise_error(ArgumentError)
      end
      
      it 'should look up the status file for the nozzle' do
        mock(@gyno).status_file(@name) { @file }
        @gyno.save_douched_statuses(@name, @hash)
      end
      
      it 'should write a yaml version of the statuses hash to the status file' do
        mock(@gyno).file_create(@file, YAML.dump(@hash))
        @gyno.save_douched_statuses(@name, @hash)
      end
      
      it 'should return true if writing the status file succeeds' do
        @gyno.save_douched_statuses(@name, @hash).should be_true
      end
      
      it 'should return false if writing the status file fails' do
        stub(@gyno).file_create(@file, anything) { raise Errno::ENOENT }
        @gyno.save_douched_statuses(@name, @hash).should be_false
      end
    end
  end
end
