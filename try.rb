require 'rubygems'
require 'isolate/now'
require 'nokogiri'
require 'open-uri'
require 'uri'

file = ARGV.shift
raise "cannot find file: #{file}" unless File.exists?(file)

binary = 'lastfmfpclient'
xml = `#{binary} "#{file}"`
doc = Nokogiri::XML(xml)

def escape_url_component(component)
  URI.escape(component.gsub(' ', '+'))
end

def album_url(artist, name)
  "http://www.last.fm/music/#{escape_url_component(artist)}/_/#{escape_url_component(name)}/+albums"
end

tracks = doc.xpath('//tracks/track')
raise "No matching songs found" unless tracks.size > 0 
track    = tracks.first
rank     = track['rank'].to_f
name     = track.xpath('name').text
artist   = track.xpath('artist/name').text
duration = track.xpath('duration').text
url      = track.xpath('url').text
albumurl = album_url(artist, name)

puts "(#{rank}) File [#{file}]\n  name[#{name}]\n  artist[#{artist}]\n  duration[#{duration}]\n  url[#{url}]\n  albumurl[#{albumurl}]"

albumpage = Nokogiri::HTML(open(albumurl))
albumlinks = albumpage.css('ul.albums li div strong a')
raise "NO ALBUMS FOUND" unless albumlinks.size > 0

albumlinks.each do |link|
  puts "    album: \"#{link.text.strip}\" => http://www.last.fm#{link['href']}"
end

