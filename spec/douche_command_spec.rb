require File.expand_path(File.dirname(__FILE__) + '/spec_helper.rb')

require 'douche'

describe 'douche command' do

  def run_command
    eval File.read(File.join(File.dirname(__FILE__), *%w[.. bin douche]))
  end
  
  describe 'when no command-line arguments are specified' do
    before :each do
      Object.send(:remove_const, :ARGV)
      ARGV = []
    end  

    it 'should run' do
      lambda { run_command }.should_not raise_error(Errno::ENOENT)
    end

    it 'should create a Douche instance' do
      mock(Douche).new(anything)
      run_command
    end
    
    it 'should set the directory option to the current directory' do
      stub.proxy(Douche).new(:directory => Dir.pwd)
    end
  end
  
  describe 'when a directory is provided on the command-line' do
    before :each do
      @dir = '/foo/bar'
    end
    
    describe 'by --dir' do
      before :each do
        Object.send(:remove_const, :ARGV)
        ARGV = ["--dir", @dir]        
      end
      
      it 'should pass the directory when creating a Douche instance' do
        mock(Douche).new({:directory => @dir})
        run_command
      end
    end
    
    describe 'by -d' do
      before :each do
        Object.send(:remove_const, :ARGV)
        ARGV = ["-d", @dir]        
      end
      
      it 'should pass the directory when creating a Douche instance' do
        mock(Douche).new({:directory => @dir})
        run_command        
      end
    end
  end
end