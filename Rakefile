def say(m); puts "** #{m}"; end

task :pages do
  require 'cgi'
  gem 'rdiscount'
  require 'github/markup'
  require 'nokogiri'
  
  readme = Dir["README*"].first
  raise "no README?" unless readme
  
  index = Nokogiri::XML(File.read("index.html.template"))
  
  index.at_css("body").content = 
    GitHub::Markup.render(readme, File.read(readme))
  
  File.open("index.html", "w") { |f| f.puts CGI.unescapeHTML(index.to_html) }
  say "index.html updated"
end
