namespace :github do
  namespace :pages do
    task :readme do
      puts "** loading..."
      require 'cgi'
      gem     'rdiscount'
      require 'github/markup'
      require 'nokogiri'
      
      puts "** processing..."
      # Checkout README.* from master, courtesy of wereHamster in #git on freenode
      system "git ls-tree master | grep README | head -n1 | while read mode type hash path; do git checkout master -- $path; done"
      readme = Dir["README*"].first
      raise "failed to checkout README.* from master" unless readme
      
      index = Nokogiri::XML(File.read("index.html.template"))
      
      index.at_css("body").content = 
        GitHub::Markup.render(readme, File.read(readme))
      
      File.open("index.html", "w") { |f| f.puts CGI.unescapeHTML(index.to_html) }
      
      File.delete readme
      
      puts "** done: index.html updated"
    end
  end
end
