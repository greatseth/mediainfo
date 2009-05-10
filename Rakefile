require "rake/testtask"
load "Rakefile.cloud" if File.exist? "Rakefile.cloud"

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/*_test.rb"]
  t.verbose = true
end

task :default => :test

namespace :mediainfo do
  task :fixture do
    unless file = ENV["file"]
      puts "Usage: rake mediainfo:fixture file=/path/to/file"
      exit
    end
    fixture = File.expand_path "./test/fixtures/#{File.basename file}.txt"
    system "mediainfo #{file} > #{fixture}"
    if File.exist? fixture
      puts "Generated fixture #{fixture}."
    else
      puts "Error generating fixture. #{fixture} not created."
    end
  end
end

require "rubygems"
require "echoe"

Echoe.new "mediainfo" do |p|
  p.author = "Seth Thomas Rasmussen"
  p.email = "sethrasmussen@gmail.com"
  p.url = "http://greatseth.com"
  p.ignore_pattern = %w( test/**/* )
end
