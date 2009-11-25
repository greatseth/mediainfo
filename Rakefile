namespace :github do
  namespace :pages do
    task :readme do
      puts "** loading..."
      require 'cgi'
      gem     'rdiscount'
      require 'github/markup'
      require 'nokogiri'
      
      puts "** processing..."
      readme = Dir["README*"].first
      raise "no README?" unless readme
      
      index = Nokogiri::XML(File.read("index.html.template"))
      
      index.at_css("body").content = 
        GitHub::Markup.render(readme, File.read(readme))
      
      File.open("index.html", "w") { |f| f.puts CGI.unescapeHTML(index.to_html) }
      
      puts "** done: index.html updated"
    end
  end
end
