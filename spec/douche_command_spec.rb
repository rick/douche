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
      
      it 'should pass the directory option when creating a Douche instance' do
        mock(Douche).new({:directory => @dir}) { @douche }
        run_command
      end
    end
    
    describe 'by -d' do
      before :each do
        Object.send(:remove_const, :ARGV)
        ARGV = ["-d", @dir]        
      end
      
      it 'should pass the directory option when creating a Douche instance' do
        mock(Douche).new({:directory => @dir}) { @douche }
        run_command        
      end
    end
  end

  describe 'when a status directory is provided on the command-line' do
    before :each do
      @dir = '/foo/bar'
    end
    
    describe 'by --status' do
      before :each do
        Object.send(:remove_const, :ARGV)
        ARGV = ["--status", @dir]        
      end
      
      it 'should pass the status_path option when creating a Douche instance' do
        mock(Douche).new(@default_options.merge(:status_path => @dir)) { @douche }
        run_command
      end
    end
    
    describe 'by -s' do
      before :each do
        Object.send(:remove_const, :ARGV)
        ARGV = ["-s", @dir]        
      end
      
      it 'should pass the status_path option when creating a Douche instance' do
        mock(Douche).new(@default_options.merge(:status_path => @dir)) { @douche }
        run_command        
      end
    end
  end

  describe 'when a configuration file is provided on the command-line' do
    before :each do
      @config_file = '/path/to/.douche.yml'
    end
    
    describe 'by --config' do
      before :each do
        Object.send(:remove_const, :ARGV)
        ARGV = ["--config", @config_file]        
      end
      
      it 'should pass the config_file option when creating a Douche instance' do
        mock(Douche).new(@default_options.merge(:config_file => @config_file)) { @douche }
        run_command
      end
    end
    
    describe 'by -c' do
      before :each do
        Object.send(:remove_const, :ARGV)
        ARGV = ["-c", @config_file]        
      end
      
      it 'should pass the config_file option when creating a Douche instance' do
        mock(Douche).new(@default_options.merge(:config_file => @config_file)) { @douche }
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
      
      it 'should pass the dry-run option when creating a Douche instance' do
        mock(Douche).new(@default_options.merge(:dry_run => true)) { @douche }
        run_command
      end
    end
    
    describe 'by -n' do
      before :each do
        Object.send(:remove_const, :ARGV)
        ARGV = ["-n"]
      end
      
      it 'should pass the dry-run option when creating a Douche instance' do
        mock(Douche).new(@default_options.merge(:dry_run => true)) { @douche }
        run_command        
      end
    end
  end
  
  describe 'when a verbose output is specified on the command-line' do
    describe 'by --verbose' do
      before :each do
        Object.send(:remove_const, :ARGV)
        ARGV = ["--verbose"]        
      end
      
      it 'should pass the verbose option when creating a Douche instance' do
        mock(Douche).new(@default_options.merge(:verbose => true)) { @douche }
        run_command
      end
    end
    
    describe 'by -v' do
      before :each do
        Object.send(:remove_const, :ARGV)
        ARGV = ["-v"]
      end
      
      it 'should pass the verbose option when creating a Douche instance' do
        mock(Douche).new(@default_options.merge(:verbose => true)) { @douche }
        run_command        
      end
    end
  end
  
  describe 'when help is requested on the command-line' do
    before :each do
      stub(self).exit { 0 }
    end
    
    describe 'by --help' do
      before :each do
        Object.send(:remove_const, :ARGV)
        ARGV = ["--help"]        
      end
      
      it 'should output a help message' do
        mock(self).puts(anything)
        run_command
      end
      
      it 'should exit' do
        stub(self).puts(anything) { nil }
        mock(self).exit
        run_command
      end
    end
    
    describe 'by -h' do
      before :each do
        Object.send(:remove_const, :ARGV)
        ARGV = ["-h"]        
      end
      
      it 'should output a help message' do
        mock(self).puts(anything)
        run_command
      end
      
      it 'should exit' do
        stub(self).puts(anything) { nil }
        mock(self).exit
        run_command
      end
    end
  end
  
  it 'should call douche on the created Douche instance' do
    mock(@douche).douche
    run_command
  end
end
