#!/usr/bin/env ruby

require 'nokogiri'
require 'open-uri'
require 'terminal-table'

if ARGV.size < 1
  puts "Usage: #{__FILE__} <search query>" 
  exit
end

query = ARGV.join("%20")
entries = []
max_entry = 0

cols = Integer(%x(tput cols))
doc = Nokogiri::HTML(open("http://thesaurus.com/browse/#{query}"))

doc.css('.relevancy-list .text').each do |entry|
  entries.push(entry.content)
  max_entry = [max_entry, entry.content.length].max
end

doc.css('.heading-row h2').each do |entry|
  puts "\n#{entry.content.strip.tr("\n", "").squeeze(" ")}? or:" if entry.content.include? "Did you mean"
end

if entries.length < 1
  puts "No synonyms found."
  exit
end

table = Terminal::Table.new do |t|
  entries.each_slice((cols / max_entry)) do |a|
    t.add_row(a)
  end
end

table.style = {:border_x => " ", :border_y => "", :border_i => " "}

puts table
