require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

require 'rubygems'
require 'mp3info'
require 'sweeper'
require 'douche_config'
require 'nozzles/lastfm_tagger_nozzle'

describe LastfmTaggerNozzle do
  before :each do
    @config = DoucheConfig.new(:directory => '/path/to/something')
  end

  describe 'when initializing' do
    it 'should accept a config object' do
      lambda { LastfmTaggerNozzle.new(:foo) }.should_not raise_error(ArgumentError)
    end

    it 'should require a config object' do
      lambda { LastfmTaggerNozzle.new }.should raise_error(ArgumentError)
    end

    it 'should return a Nozzle' do
      LastfmTaggerNozzle.new(@config).is_a?(Nozzle).should be_true
    end
  end

  describe 'once initialized' do
    before :each do
      @options = { :directory => '/path/to' }
      @gyno = Gynecologist.new(@options)
      @nozzle = LastfmTaggerNozzle.new(@config)
      stub(@nozzle).status { @gyno }
      @name = 'copy'
      stub(@nozzle).name { @name }
      stub(@nozzle).params { { } }
      @file = '/path/to/some_file'
      @sweeper = { }
      stub(@sweeper).lookup(@file) { { } }
      stub(Sweeper).new { @sweeper }
    end

    it 'should allow tagging a file via last.fm' do
      @nozzle.should respond_to(:lastfm_tag)
    end

    describe 'when tagging a file via last.fm' do
      before :each do
        stub(@nozzle).puts(anything)
        stub(Sweeper).new { @sweeper }
        stub(@nozzle).sweeper { @sweeper }
        @lastfm = { 'title' => 'Shoot to Thrill', 'artist' => 'AC/DC', 'url' => 'http://last.fm' }
      end

      it 'should accept a filename' do
        lambda { @nozzle.lastfm_tag(@file) }.should_not raise_error(ArgumentError)
      end

      it 'should require a filename' do
        lambda { @nozzle.lastfm_tag }.should raise_error(ArgumentError)
      end

      it 'should call the last.fm tagger with the filename' do
        mock(@sweeper).lookup(@file) { @tags }
        @nozzle.lastfm_tag(@file)
      end

      describe 'if the last.fm tagger fails' do
        before :each do
          stub(@sweeper).lookup(@file) { raise "Fail!!!" }
        end

        it 'should record the error' do
          mock(@nozzle).flag_error(@file)
          @nozzle.lastfm_tag(@file)
        end

        it 'should not tag the file' do
          mock(@nozzle).tag_file(@file, anything).never
          @nozzle.lastfm_tag(@file)
        end

        it 'should return false' do
          @nozzle.lastfm_tag(@file).should be_false
        end
      end

      describe 'if the last.fm tagger returns no results' do
        before :each do
          stub(@sweeper).lookup(@file) { nil }
        end

        it 'should not tag the file' do
          mock(@nozzle).tag_file(@file, anything).never
          @nozzle.lastfm_tag(@file)
        end

        it 'should return false' do
          @nozzle.lastfm_tag(@file).should be_false
        end
      end

      describe 'if the last.fm tagger returns no title in the results' do
        before :each do
          stub(@sweeper).lookup(@file) { @lastfm.merge('title' => '') }
        end

        it 'should not tag the file' do
          mock(@nozzle).tag_file(@file, anything).never
          @nozzle.lastfm_tag(@file)
        end

        it 'should return false' do
          @nozzle.lastfm_tag(@file).should be_false
        end
      end

      describe 'if the last.fm tagger returns no artist in the results' do
        before :each do
          stub(@sweeper).lookup(@file) { @lastfm.merge('artist' => '') }
        end

        it 'should not tag the file' do
          mock(@nozzle).tag_file(@file, anything).never
          @nozzle.lastfm_tag(@file)
        end

        it 'should return false' do
          @nozzle.lastfm_tag(@file).should be_false
        end
      end

      describe 'if the last.fm tagger returns no URL in the results' do
        before :each do
          stub(@sweeper).lookup(@file) { @lastfm.merge('url' => '') }
        end

        it 'should not tag the file' do
          mock(@nozzle).tag_file(@file, anything).never
          @nozzle.lastfm_tag(@file)
        end

        it 'should return false' do
          @nozzle.lastfm_tag(@file).should be_false
        end
      end

      describe 'if the last.fm tagger returns good results' do
        before :each do
          stub(@nozzle).sweeper { @sweeper }
          stub(@sweeper).lookup(@file) { @lastfm }
        end

        it 'should tag the file with the results' do
          mock(@nozzle).tag_file(@file, @lastfm) { true }
          @nozzle.lastfm_tag(@file)
        end

        it 'should return false if tagging the file returns false' do
          stub(@nozzle).tag_file(@file, anything) { false }
          @nozzle.lastfm_tag(@file).should be_false
        end

        it 'should return true if tagging the file returns true' do
          stub(@nozzle).tag_file(@file, anything) { true }
          @nozzle.lastfm_tag(@file).should be_true
        end
      end
    end

    it 'should allow applying id3v2 tags to a file' do
      @nozzle.should respond_to(:tag_file)
    end

    describe 'when applying id3v2 tags to a file' do
      before :each do
        stub(@nozzle).puts(anything)
        stub(Mp3Info).open(@file) { { } }
        @tags = { }
      end

      it 'should accept a file and a set of tags' do
        lambda { @nozzle.tag_file(@file, @tags) }.should_not raise_error(ArgumentError)
      end

      it 'should require a file and a set of tags' do
        lambda { @nozzle.tag_file(@file) }.should raise_error(ArgumentError)
      end

      it 'should update the tags on the file' do
        mock(Mp3Info).open(@file) { { } }
        @nozzle.tag_file(@file, @tags)
      end

      it 'should return false if tagging fails' do
        stub(Mp3Info).open(@file) { raise "FAIL!" }
        @nozzle.tag_file(@file, @tags).should be_false
      end


      it 'should return true if tagging succeeds' do
        @nozzle.tag_file(@file, @tags).should be_true
      end
    end

    it 'should allow checking if the file has already been tagged' do
      @nozzle.should respond_to(:already_tagged?)
    end

    describe 'when checking if the file has already been tagged' do
      before :each do
        stub(@nozzle).puts(anything)
        @tags = { }
        stub(@tags).UFID { 'http://www.last.fm/music/Marvin+Gaye/_/Marvin%27s+Message+to+CBS+Records+Staff' }
        @mp3info = { }
        stub(@mp3info).tag2 { @tags }
        stub(Mp3Info).open(@file) { @mp3info }
      end

      it 'should accept a filename' do
        lambda { @nozzle.already_tagged?(@file) }.should_not raise_error(ArgumentError)
      end

      it 'should require a filename' do
        lambda { @nozzle.already_tagged? }.should raise_error(ArgumentError)
      end

      it 'should read the id3v2 tags from the file' do
        mock(Mp3Info).open(@file) { @mp3info }
        @nozzle.already_tagged?(@file)
      end

      it 'should return false if the id3v2 lookup fails' do
        mock(Mp3Info).open(@file) { raise "Fail!" }
        @nozzle.already_tagged?(@file).should be_false
      end

      it 'should return false if the id3v2 tags do not have an UFID' do
        stub(@tags).UFID { '' }
        @nozzle.already_tagged?(@file).should be_false
      end

      it 'should return true if the id3v2 tags include an UFID' do
        stub(@tags).UFID { 'http://www.last.fm/music/Marvin+Gaye/_/Marvin%27s+Message+to+CBS+Records+Staff' }
        @nozzle.already_tagged?(@file).should be_true
      end
    end

    describe 'when checking if a file is stank' do
      before :each do
        stub(@nozzle).flagged_with_error?(@file) { false }
      end

      it 'should accept a filename' do
        lambda { @nozzle.stank?(:foo) }.should_not raise_error(ArgumentError)
      end

      it 'should require a filename' do
        lambda { @nozzle.stank? }.should raise_error(ArgumentError)
      end

      describe 'when there is a pattern specified in params and the file does not match' do
        before :each do
          stub(@nozzle).params { { 'pattern' => '\.flac$' } }
        end

        it 'should return false' do
          @nozzle.stank?('/path/to/some.mp3').should be_false
        end
      end

      it "should check if the file has already been processed before" do
        mock(@nozzle).douched?(@file) { true }
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

        it 'should check if the file has a recorded tagging error' do
          mock(@nozzle).flagged_with_error?(@file) { false }
          @nozzle.stank?(@file)
        end

        it 'should return false if the file has a recorded tagging error' do
          stub(@nozzle).flagged_with_error?(@file) { true }
          @nozzle.stank?(@file).should be_false
        end

        it 'should check if the file has full id3v2 tags' do
          mock(@nozzle).already_tagged?(@file) { false }
          @nozzle.stank?(@file)
        end

        it 'should return true if the file does not have an id3v2 title tag' do
          stub(@nozzle).already_tagged?(@file) { false }
          @nozzle.stank?(@file).should be_true
        end

        it 'should return false if the file has an id3v2 title tag' do
          stub(@nozzle).already_tagged?(@file) { true }
          @nozzle.stank?(@file).should be_false
        end
      end
    end

    it 'should have a means of marking a file as having an encoding error' do
      @nozzle.should respond_to(:flag_error)
    end

    describe 'when marking a file as having an encoding error' do
      before :each do
        @badfile = File.join(File.dirname(@file), ".douche_error_lastfm_tagging-#{File.basename(@file, '.mp3')}")
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

    it 'should allow checking if a file has been flagged with an error' do
      @nozzle.should respond_to(:flagged_with_error?)
    end

    describe 'when checking if a file has been flagged with an error' do
      it 'should accept a filename' do
        lambda { @nozzle.flagged_with_error?(@file) }.should_not raise_error(ArgumentError)
      end

      it 'should require a filename' do
        lambda { @nozzle.flagged_with_error? }.should raise_error(ArgumentError)
      end

      it 'should return true if an error file is present' do
        stub(File).file?("/path/to/.douche_error_lastfm_tagging-some_file") { true }
        @nozzle.flagged_with_error?(@file).should be_true
      end

      it 'should return false if an error file is not present' do
        stub(File).file?("/path/to/.douche_error_lastfm_tagging-some_file") { false }
        @nozzle.flagged_with_error?(@file).should be_false
      end
    end

    describe 'when spraying a file' do
      before :each do
        stub(@nozzle).puts(anything)
        @file = '/path/to/artist/album/filename'
        @relative_path = '/artist/album'
        stub(@nozzle).params { { } }
        stub(@nozzle).relative_path { @relative_path }
        stub(@nozzle).copy(anything, anything) { true }
        stub(@nozzle).douched(@file)
        stub(@nozzle).normalize('filename') { 'normal_file' }
        stub(@nozzle).normalize(@relative_path) { 'normal_path'  }
      end

      it 'should accept a filename' do
        lambda { @nozzle.spray(@file) }.should_not raise_error(ArgumentError)
      end

      it 'should require a filename' do
        lambda { @nozzle.spray }.should raise_error(ArgumentError)
      end

      it 'should attempt to use last.fm to tag the file' do
        mock(@nozzle).lastfm_tag(@file)
        @nozzle.spray(@file)
      end

      describe 'if the tagging succeeds' do
        before :each do
          stub(@nozzle).lastfm_tag(@file) { true }
        end

        it 'should mark the file as douched' do
          mock(@nozzle).douched(@file)
          @nozzle.spray(@file)
        end

        it 'should return true' do
          @nozzle.spray(@file).should be_true
        end
      end

      describe 'if the tagging fails' do
        before :each do
          stub(@nozzle).lastfm_tag(@file) { false }
        end

        it 'should not mark the file as douched' do
          mock(@nozzle).douched.never
          @nozzle.spray(@file)
        end

        it 'should return false' do
          @nozzle.spray(@file).should be_false
        end
      end
    end
  end
end
