require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

require 'rubygems'
require 'mp3info'
require 'douche_config'
require 'nozzles/init_id3v2_tags_nozzle'

describe InitId3v2TagsNozzle do
  before :each do
    @config = DoucheConfig.new(:directory => '/path/to/something')
  end

  describe 'when initializing' do
    it 'should accept a config object' do
      lambda { InitId3v2TagsNozzle.new(:foo) }.should_not raise_error(ArgumentError)
    end

    it 'should require a config object' do
      lambda { InitId3v2TagsNozzle.new }.should raise_error(ArgumentError)
    end

    it 'should return a Nozzle' do
      InitId3v2TagsNozzle.new(@config).is_a?(Nozzle).should be_true
    end
  end

  describe 'once initialized' do
    before :each do
      @options = { :directory => '/path/to' }
      @gyno = Gynecologist.new(@options)
      @nozzle = InitId3v2TagsNozzle.new(@config)
      stub(@nozzle).status { @gyno }
      @name = 'copy'
      stub(@nozzle).name { @name }
      @file = '/path/to/some_file'
    end

    it 'should have a means of determining if id3v2 tags are needed for a file' do
      @nozzle.should respond_to(:needs_v2_tags?)
    end

    describe 'when determining if id3v2 tags are needed for a file' do
      before :each do
        @info = { }
        stub(@info).hastag1? { false }
        stub(@info).hastag2? { false }
        stub(Mp3Info).open(@file) { @info }
      end

      it 'should accept a file path' do
        lambda { @nozzle.needs_v2_tags?(@file) }.should_not raise_error(ArgumentError)
      end

      it 'should require a file path' do
        lambda { @nozzle.needs_v2_tags? }.should raise_error(ArgumentError)
      end

      it 'should read the id3 tag info for the file' do
        mock(Mp3Info).open(@file) { @info }
        @nozzle.needs_v2_tags?(@file)
      end

      it 'should return true when there are no id3v2 tags for the file' do
        stub(@info).hastag1? { false }
        stub(@info).hastag2? { false }
        @nozzle.needs_v2_tags?(@file).should be_true
      end

      it 'should return false when there are id3v2 tags for the file' do
        stub(@info).hastag2? { true }
        @nozzle.needs_v2_tags?(@file).should be_false
      end

      it 'should raise an Mp3InfoError when the id3 tags are unreadable' do
        mock(Mp3Info).open(@file) { raise Mp3InfoError }
        lambda { @nozzle.needs_v2_tags?(@file) }.should raise_error(Mp3InfoError)
      end
    end

    it 'should have a means of upgrading id3 tags' do
      @nozzle.should respond_to(:upgrade_tags)
    end

    describe 'when upgrading id3 tags' do
      it 'should accept a file path' do
        lambda { @nozzle.upgrade_tags(@file) }.should_not raise_error(ArgumentError)
      end

      it 'should require a file path' do
        lambda { @nozzle.upgrade_tags }.should raise_error(ArgumentError)
      end

      it 'should set id3v2 tags for artist, album, genre, and title from the id3v1 tags' do
        pending("figuring out how to test this")
        @nozzle.upgrade_tags(@file)
      end
    end

    it 'should have a means of marking a file as having an encoding error' do
      @nozzle.should respond_to(:flag_error)
    end

    describe 'when marking a file as having an encoding error' do
      before :each do
        @badfile = File.join(File.dirname(@file), ".douche_error_encoding-#{File.basename(@file, '.mp3')}")
        stub(File).open(@badfile, 'w')
      end

      it 'should accept a file path' do
        lambda { @nozzle.flag_error(@file) }.should_not raise_error(ArgumentError)
      end

      it 'should require a file path' do
        lambda { @nozzle.flag_error }.should raise_error(ArgumentError)
      end

      it 'should touch a bad encoding file for the provided file' do
        mock(File).open(@badfile, 'w')
        @nozzle.flag_error(@file)
      end
    end

    describe 'when checking if a file is stank' do
      it 'should accept a filename' do
        lambda { @nozzle.stank?(:foo) }.should_not raise_error(ArgumentError)
      end

      it 'should require a filename' do
        lambda { @nozzle.stank? }.should raise_error(ArgumentError)
      end

      before :each do
        stub(@nozzle).params { { } }
      end

      describe 'when there is a pattern specified in params and the file does not match' do
        before :each do
          stub(@nozzle).params { { 'pattern' => '\.mp3$' } }
        end

        it 'should return false' do
          @nozzle.stank?('/path/to/some.mp4').should be_false
        end
      end

      it "should check if the file has already been processed before" do
        mock(@nozzle).douched?(@file)
        @nozzle.stank?(@file)
      end

      describe 'if the file has already been processed before' do
        before :each do
          stub(@nozzle).douched?(@file) { true }
        end

        it 'should return false' do
          @nozzle.stank?(@file).should be_false
        end
      end

      describe 'if the file has not been processed before' do
        before :each do
          stub(@nozzle).douched?(@file) { false }
        end

        it 'should return true' do
          @nozzle.stank?(@file).should be_true
        end
      end
    end

    describe 'when spraying a file' do
      before :each do
        @file = '/path/to/artist/album/filename'
        @relative_path = '/artist/album'
        stub(@nozzle).params { { } }
        stub(@nozzle).douched(@file)
        stub(@nozzle).needs_v2_tags?(@file) { false }
        stub(@nozzle).flag_error(@file)
      end

      it 'should accept a filename' do
        lambda { @nozzle.spray(@file) }.should_not raise_error(ArgumentError)
      end

      it 'should require a filename' do
        lambda { @nozzle.spray }.should raise_error(ArgumentError)
      end

      it 'should check whether the file needs id3v2 tags' do
        mock(@nozzle).needs_v2_tags?(@file)
        @nozzle.spray(@file)
      end

      describe 'when the id3v2 tags cannot be read' do
        before :each do
          stub(@nozzle).needs_v2_tags?(@file) { raise Mp3InfoError }
        end

        it 'should output a warning' do
          mock(@nozzle).puts(anything)
          @nozzle.spray(@file)
        end

        it 'should create a bad-encoding marker file' do
          mock(@nozzle).flag_error(@file)
          @nozzle.spray(@file)
        end

        it 'should not upgrade id3v2 tags' do
          mock(@nozzle).upgrade_tags(@file).never
          @nozzle.spray(@file)
        end

        it 'should mark the file as douched' do
          mock(@nozzle).douched(@file)
          @nozzle.spray(@file)
        end

        it 'should return true' do
          @nozzle.spray(@file).should be_true
        end
      end

      describe 'when the file has valid id3v2 tags' do
        before :each do
          stub(@nozzle).needs_v2_tags?(@file) { false }
        end

        it 'should not create a bad-encoding marker file' do
          mock(@nozzle).flag_error(@file).never
          @nozzle.spray(@file)
        end

        it 'should not upgrade id3v2 tags' do
          mock(@nozzle).upgrade_tags(@file).never
          @nozzle.spray(@file)
        end

        it 'should mark the file as douched' do
          mock(@nozzle).douched(@file)
          @nozzle.spray(@file)
        end

        it 'should return true' do
          @nozzle.spray(@file).should be_true
        end
      end

      describe 'when the file has no id3v2 tags' do
        before :each do
          stub(@nozzle).needs_v2_tags?(@file) { true }
        end

        it 'should not create a bad-encoding marker file' do
          mock(@nozzle).flag_error(@file).never
          @nozzle.spray(@file)
        end

        it 'should upgrade id3v2 tags' do
          mock(@nozzle).upgrade_tags(@file)
          @nozzle.spray(@file)
        end

        it 'should mark the file as douched' do
          mock(@nozzle).douched(@file)
          @nozzle.spray(@file)
        end

        it 'should return true' do
          @nozzle.spray(@file).should be_true
        end
      end
    end
  end
end
