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

    it "should allow locating a gyno's status file" do
      @gyno.should respond_to(:status_file)
    end

    describe "when locating a nozzle's status file" do
      before :each do
        @directory = '/the/main/path'
        stub(@gyno).directory { @directory }
        ENV['HOME'] = '/home/someuser'
      end

      it 'should accept a nozzle name' do
        lambda { @gyno.status_file(@name) }.should_not raise_error(ArgumentError)
      end

      it 'should require a nozzle name' do
        lambda { @gyno.status_file }.should raise_error(ArgumentError)
      end

      describe 'when no status path was provided as an option' do
        it 'should create the ~/.douche directory if it does not exist' do
          stub(File).directory?(File.join(ENV['HOME'], '.douche')) { false }
          mock(File).makedirs(File.join(ENV['HOME'], '.douche'))
          @gyno.status_file(@name)
        end

        it 'should not create the ~/.douche directory if it already exists' do
          stub(File).directory?(File.join(ENV['HOME'], '.douche')) { true }
          mock(File).makedirs(File.join(ENV['HOME'], '.douche')).never
          @gyno.status_file(@name)
        end

        it "should return a gyno-named filename in the users ~/.douche directory" do
          @gyno.status_file('shizzle').should == File.join(ENV['HOME'], '.douche', '.douche_shizzle')
        end
      end

      describe 'when a status path was provided as an option' do
        before :each do
          @status_path = '/path/to/statuses'
          @gyno = Gynecologist.new(:status_path => @status_path)
        end

        it 'should create the status path directory if it does not exist' do
          stub(File).directory?(@status_path) { false }
          mock(File).makedirs(@status_path)
          @gyno.status_file(@name)
        end

        it 'should not create the status path directory if it already exists' do
          stub(File).directory?(@status_path) { true }
          mock(File).makedirs(@status_path).never
          @gyno.status_file(@name)
        end

        it "should return a gyno-named filename in the status path directory" do
          @gyno.status_file('shizzle').should == File.join(@status_path, '.douche_shizzle')
        end
      end
    end

    it 'should allow checking whether a file has been douched by a nozzle' do
      @gyno.should respond_to(:douched?)
    end

    describe 'when checking whether a file has been douched by a nozzle' do
      before :each do
        @name = 'shizzle'
        @file = '/path/to/file'
        @status_file = '/path/to/status/file'
        stub(@gyno).status_file(@name) { @status_file }
        stub(File).open(@status_file, 'r')
      end

      it 'should accept a nozzle name and a file path' do
        lambda { @gyno.douched?(@name, @file) }.should_not raise_error(ArgumentError)
      end

      it 'should require a nozzle name and a file path' do
        lambda { @gyno.douched?(@name) }.should raise_error(ArgumentError)
      end

      it 'should look up the status file' do
        mock(@gyno).status_file(@name) { @status_file }
        @gyno.douched?(@name, @file)
      end
      
      it 'should open the status file' do
        mock(File).open(@status_file, 'r')
        @gyno.douched?(@name, @file)
      end

      it 'should return false if the status file cannot be opened' do
        stub(File).open(@status_file, 'r') { raise Errno::ENOENT }
        @gyno.douched?(@name, @file).should be_false
      end
      
      it 'should return true if the status file contains the named file' do
        pending('figuring out how to test this')
      end

      it 'should return false if the status file does not contain the named file' do
        pending('figuring out how to test this')
      end
    end

    it 'should allow marking a file as douched by a nozzle' do
      @gyno.should respond_to(:douched)
    end

    describe 'when marking a file as douched by a nozzle' do
      before :each do
        @name = 'shizzle'
        @status_file = '/path/to/.douche_shizzle'
        @douched_file = '/some/douched/file'
        stub(@gyno).status_file(@name) { @status_file }
      end

      it 'should accept a nozzle name and a statuses hash' do
        lambda { @gyno.douched(@name, @douched_file)}.should_not raise_error(ArgumentError)
      end

      it 'should require a nozzle name and a statuses hash' do
        lambda { @gyno.douched(@name) }.should raise_error(ArgumentError)
      end

      it 'should look up the status file for the nozzle' do
        mock(@gyno).status_file(@name) { @status_file }
        @gyno.douched(@name, @douched_file)
      end

      it 'should append a yaml line for the new file' do
        mock(File).open(@status_file, 'a+')
        @gyno.douched(@name, @douched_file)
      end
      
      it 'should return true if writing the status file succeeds' do
        stub(File).open(@status_file, 'a+')
        @gyno.douched(@name, @douched_file).should be_true
      end
      
      it 'should return false if writing the status file fails' do
        stub(File).open(@status_file, 'a+'){ raise Errno::ENOENT }
        @gyno.douched(@name, @douched_file).should be_false
      end
    end
  end
end
