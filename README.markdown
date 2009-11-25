# Mediainfo

Mediainfo is a class wrapping [the mediainfo CLI](http://mediainfo.sourceforge.net).

## Installation
  
    $ gem install mediainfo -s http://gemcutter.org
  
## Usage
  
    info = Mediainfo.new "/path/to/file"
  
That will issue the system call to `mediainfo` and parse the output. 
You can specify an alternate path if necessary:
  
    Mediainfo.path = "/opt/local/bin/mediainfo"
  

By default, REXML is used as the XML parser. If you'd like, you can 
configure Mediainfo to use Hpricot or Nokogiri instead using one of 
the following approaches:

  * define the `MEDIAINFO_XML_PARSER` environment variable to be the 
    name of the parser as you'd pass to a :gem or :require call. 
    
    e.g. `export MEDIAINFO_XML_PARSER=nokogiri`
    
  * assign to Mediainfo.xml_parser after you've loaded the gem, 
    following the same naming conventions mentioned previously.
    
    e.g. `Mediainfo.xml_parser = "hpricot"`
    

Once you've got an instance setup, you can call numerous methods to get 
a variety of information about a file. Some attributes may be present 
for some files where others are not, but any supported attribute 
should at least return `nil`.

For a list of all possible attributes supported:
  
    Mediainfo.supported_attributes
  
## Requirements

This requires at least the following version of the Mediainfo CLI:
  
    MediaInfo Command line,
    MediaInfoLib - v0.7.25
  
Previous versions of this gem(<= 0.5.1) worked against v0.7.11, which did not 
generate XML output, and is no longer supported.

## Contributors

* Seth Thomas Rasmussen - [http://greatseth.com](http://greatseth.com)
* Peter Vandenberk - [http://github.com/pvdb](http://github.com/pvdb)
