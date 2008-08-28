require File.expand_path(File.dirname(__FILE__) + '/spec_helper.rb')

require 'douche'

describe 'douche command' do
  
  before :each do
    @default_options = { :directory => Dir.pwd }
    @douche = Object.new
    stub(Douche).new { @douche }
    stub(@douche).douche { true }
  end

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
      mock(Douche).new(anything) { @douche }
      run_command
    end
    
    it 'should set the directory option to the current directory' do
      stub.proxy(Douche).new(:directory => Dir.pwd) { @douche }
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
        mock(Douche).new({:directory => @dir}) { @douche }
        run_command
      end
    end
    
    describe 'by -d' do
      before :each do
        Object.send(:remove_const, :ARGV)
        ARGV = ["-d", @dir]        
      end
      
      it 'should pass the directory when creating a Douche instance' do
        mock(Douche).new({:directory => @dir}) { @douche }
        run_command        
      end
    end
  end

  describe 'when a dry run is specified on the command-line' do
    describe 'by --dry-run' do
      before :each do
        Object.send(:remove_const, :ARGV)
        ARGV = ["--dry-run"]        
      end
      
      it 'should pass the dry-run argument when creating a Douche instance' do
        mock(Douche).new(@default_options.merge(:dry_run => true)) { @douche }
        run_command
      end
    end
    
    describe 'by -n' do
      before :each do
        Object.send(:remove_const, :ARGV)
        ARGV = ["-n"]
      end
      
      it 'should pass the directory when creating a Douche instance' do
        mock(Douche).new(@default_options.merge(:dry_run => true)) { @douche }
        run_command        
      end
    end
  end
  
  it 'should call douche on the created Douche instance' do
    mock(@douche).douche
    run_command
  end
end