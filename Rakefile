require "rubygems"
require "echoe"

class Echoe
  def honor_gitignore!
    self.ignore_pattern += \
      Dir["**/.gitignore"].inject([]) do |pattern,gitignore| 
        pattern.concat \
          File.readlines(gitignore).
            map    { |line| line.strip }.
            reject { |line| "" == line }.
            map    { |glob| 
              d = File.dirname(gitignore)
              d == "." ? glob : File.join(d, glob)
            }
      end.flatten.uniq
  end
end

Echoe.new "mediainfo" do |p|
  p.description = p.summary = "Mediainfo is a class wrapping the mediainfo CLI (http://mediainfo.sourceforge.net)"
  p.author = "Seth Thomas Rasmussen"
  p.email = "sethrasmussen@gmail.com"
  p.url = "http://greatseth.github.com/mediainfo"
  p.ignore_pattern = %w( test/**/* )
  p.retain_gemspec = true
  p.honor_gitignore!
end

task :rexml do
  ENV.delete "MEDIAINFO_XML_PARSER"
  Rake::Task[:test].invoke
end

task :hpricot do
  ENV["MEDIAINFO_XML_PARSER"] = "hpricot"
  Rake::Task[:test].invoke
end

task :nokogiri do
  ENV["MEDIAINFO_XML_PARSER"] = "nokogiri"
  Rake::Task[:test].invoke
end

# TODO This doesn't work.
task :all => [:rexml, :nokogiri, :hpricot]


task :fixture do
  unless file = ENV["FILE"]
    puts "Usage: rake mediainfo:fixture file=/path/to/file"
    exit
  end
  fixture = File.expand_path "./test/fixtures/#{File.basename file}.xml"
  system "mediainfo #{file} --Output=XML > #{fixture}"
  if File.exist? fixture
    puts "Generated fixture #{fixture}."
  else
    puts "Error generating fixture. #{fixture} not created."
  end
end

# require 'github/pages/tasks'
