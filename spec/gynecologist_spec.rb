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
      end

      it 'should accept a nozzle name' do
        lambda { @gyno.douched_statuses(@name) }.should_not raise_error(ArgumentError)
      end

      it 'should require a nozzle name' do
        lambda { @gyno.douched_statuses }.should raise_error(ArgumentError)
      end

      describe 'the first time' do
        before :each do
          stub(@gyno).status_file(@name) { @file }
          stub(File).read(@file) { YAML.dump({}) }
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
      end

      describe 'after the first time' do
        before :each do
          @results = @gyno.douched_statuses(@name)
        end
        
        it 'should not look up the nozzle status file' do
          mock(@gyno).status_file(@name).never
          @gyno.douched_statuses(@name)
        end
        
        it 'should not read the nozzle status file' do
          mock(File).read(anything).never
          @gyno.douched_statuses(@name)
        end
        
        it 'should return the same results as the first time' do
          @gyno.douched_statuses(@name).should == @results
        end
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

      it 'should update the douched statuses with the filename' do
        @gyno.douched(@name, @file)
        @hash[@file].should be_true
      end

      it 'should add the file to douched statuses file for the nozzle' do
        mock(@gyno).update_douched_statuses(@name, @file)
        @gyno.douched(@name, @file)
      end
    end

    it 'should allow saving douched statuses for a nozzle' do
      @gyno.should respond_to(:update_douched_statuses)
    end

    describe 'when saving douched statuses for a nozzle' do
      before :each do
        @name = 'shizzle'
        @status_file = '/path/to/.douche_shizzle'
        @douched_file = '/some/douched/file'
        stub(@gyno).status_file(@name) { @status_file }
      end

      it 'should accept a nozzle name and a statuses hash' do
        lambda { @gyno.update_douched_statuses(@name, @douched_file)}.should_not raise_error(ArgumentError)
      end

      it 'should require a nozzle name and a statuses hash' do
        lambda { @gyno.update_douched_statuses(@name) }.should raise_error(ArgumentError)
      end

      it 'should look up the status file for the nozzle' do
        mock(@gyno).status_file(@name) { @status_file }
        @gyno.update_douched_statuses(@name, @douched_file)
      end

      describe 'when the status file does not already exist' do
        before :each do
          stub(File).file?(@status_file) { false }
          stub(@gyno).file_create(@status_file, anything) { true }
        end
        
        it 'should write a yaml version of the statuses hash to the status file' do
          mock(@gyno).file_create(@status_file, anything)
          @gyno.update_douched_statuses(@name, @douched_file)
        end
        
        it 'should return true if writing the status file succeeds' do
          @gyno.update_douched_statuses(@name, @douched_file).should be_true
        end

        it 'should return false if writing the status file fails' do
          stub(@gyno).file_create(@status_file, anything) { raise Errno::ENOENT }
          @gyno.update_douched_statuses(@name, @douched_file).should be_false
        end
      end

      describe 'if the status file already exists' do
        before :each do
          stub(File).file?(@status_file) { true }
        end

        it 'should not create a completely new file' do
          mock(@gyno).file_create(anything, anything).never
          @gyno.update_douched_statuses(@name, @douched_file)
        end
        
        it 'should append a yaml line for the new file' do
          mock(File).open(@status_file, 'a+')
          @gyno.update_douched_statuses(@name, @douched_file)
        end
        
        it 'should return true if writing the status file succeeds' do
          @gyno.update_douched_statuses(@name, @douched_file).should be_true
        end
        
        it 'should return false if writing the status file fails' do
          stub(File).open(@status_file, 'a+'){ raise Errno::ENOENT }
          @gyno.update_douched_statuses(@name, @douched_file).should be_false
        end
      end
    end
  end
end
