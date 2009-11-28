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
  p.description = "Mediainfo is a class wrapping the mediainfo CLI (http://mediainfo.sourceforge.net)"
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

###

namespace :github do
  namespace :pages do
    task :readme do
      puts "** loading..."
      require 'cgi'
      require 'rdiscount'
      require 'github/markup'
      require 'nokogiri'
      
      puts "** processing..."
      # Checkout README.* from master, courtesy of wereHamster in #git on freenode
      glob   = "README.*"
      readme = `ls | grep #{glob}`.strip
      raise "found no files matching #{glob.inspect}" if readme.empty?
      
      index_template = "index.html.template"
      raise "found no #{index_template.inspect}" unless File.exist? index_template
      index = Nokogiri::XML(File.read(index_template))
      
      index.at_css("body").content = 
        GitHub::Markup.render(readme, File.read(readme))
      
      gh_pages = "gh-pages"
      puts "** checking out #{gh_pages.inspect} branch..."
      system "git checkout #{gh_pages}"
      unless File.read(".git/HEAD")[%r{ref: refs/heads/#{gh_pages}}]
        raise "failed to checkout #{gh_pages.inspect}"
      end
      
      index_html = "index.html"
      puts "** #{File.exist?(index_html) ? 'updating' : 'creating'} #{index_html}..."
      File.open(index_html, "w") { |f| f.puts CGI.unescapeHTML(index.to_html) }
      system "git commit -a -m 'update #{index_html.inspect}'"
      
      puts "** switching back to last branch..."
      system "git checkout -"
    end
  end
end
