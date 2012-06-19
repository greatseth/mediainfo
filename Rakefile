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

namespace :compile do
  task :mediainfo do
    url = "http://downloads.sourceforge.net/project/mediainfo/binary/mediainfo/0.7.58/MediaInfo_CLI_0.7.58_GNU_FromSource.tar.bz2?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fmediainfo%2Ffiles%2Fbinary%2Fmediainfo%2F0.7.58%2FMediaInfo_CLI_0.7.58_GNU_FromSource.tar.bz2%2Fdownload&ts=1340119295&use_mirror=voxel"
    `mkdir -p tmp`
    `wget -O tmp/mediainfo.tar.bz2 "#{url}"`
    `cd tmp && tar xvf mediainfo.tar.bz2`
    `cd tmp/MediaInfo_CLI_GNU_FromSource && sh CLI_Compile.sh > CLI_Compile.log`
    `mkdir -p ext`
    `mv tmp/MediaInfo_CLI_GNU_FromSource/MediaInfo/Project/GNU/CLI/mediainfo ext/`

    # clean up
    `rm -rf tmp/mediainfo.tar.bz2 tmp/MediaInfo_CLI_GNU_FromSource`
  end
end

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
