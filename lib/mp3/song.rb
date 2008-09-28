module MP3
  class Song
    attr_reader :file
    
    def initialize(file)
      @file = file
    end
  end
end
