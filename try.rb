require 'find'
require 'mp3/album'
require 'rubygems'
require 'highline/import'
require 'ftools'

@path = '/Volumes/share/audio/'
@count = 0

def go(cmd)
  grey(cmd)
#  `#{cmd}`
end

def grey(str)
  say("<%= color(%q!#{str}!, :cyan) %>")
end

def red(str)
  say("<%= color(%q!#{str}!, :black, :on_red) %>")
end

def yellow(str)
  say("<%= color(%q!#{str}!, :black, :on_yellow) %>")
end

def green(str)
  say("<%= color(%q!#{str}!, :green) %>")
end

def ambiguous(dir)
  go %Q{mv "#{dir}" #{@path}/ambiguous/}
end

def duplicate(src, artist, album)
  @count += 1
  go %Q{mkdir #{@path}/duplicates/#{@count}/#{artist}}
  go %Q{mv "#{src}" #{@path}/duplicates/#{@count}/#{artist}/#{album}}
end

def fail(dir)
  @count += 1
  go %Q{mkdir #{@path}/bad/#{@count}/}
  go %Q{mv "#{dir}" #{@path}/bad/#{@count}/}
end

class String
  def normalize
    gsub(%r{[^-a-zA-Z0-9_\.]}, '_').gsub(/_+/, '_').sub(/^_/, '').sub(/_$/, '').downcase
  end
end

def rename(dir, artist, album)
  artist = artist.normalize
  album = album.normalize
  go "mkdir -p #{@path}/mp3/#{artist}"
  if File.directory?("#{@path}/mp3/#{artist}/#{album}")
    yellow "duplicate #{@path}/mp3/#{artist}/#{album}" 
    duplicate(dir, artist, album)
  else
    go %Q{mv "#{dir}" #{@path}/mp3/#{artist}/#{album}}
  end
end

Find.find("#{@path}/mp3-old") do |filename|
  next unless File.directory?(filename)
  begin
    m = MP3::Album.new(filename)
    next if m.song_files.empty?
  
    if m.multiple_artists
      if !m.name or m.name =~ /^\s*$/
        yellow "[#{filename}] -> *** Various Artists album with no name ***"
        ambiguous(filename)
      else
        green "[#{filename}] -> *Various, Album [#{m.name}]"
        rename(filename, 'Various', m.name)
      end
    else
      if !m.name or m.name =~ /^\s*$/ or !m.artist or m.artist =~ /^\s*$/
        yellow "[#{filename}] -> *** Album with blank artist [#{m.artist}] or album [#{m.name}] ***"
        ambiguous(filename)
      else
        green "[#{filename}] -> Artist [#{m.artist.inspect}], Album [#{m.name.inspect}]"
        rename(filename, m.artist, m.name)
      end
    end
  rescue Exception => e
    red "error [#{e.to_s}] on [#{filename}]"
    fail(filename)
  end
end
