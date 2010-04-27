# Mediainfo

Mediainfo is a class wrapping [the mediainfo CLI](http://mediainfo.sourceforge.net).

## Installation
    
    $ gem install mediainfo
    
## Usage
    
    info = Mediainfo.new "/path/to/file"
    
That will issue the system call to `mediainfo` and parse the output. 
You can specify an alternate path if necessary:
    
    Mediainfo.path = "/opt/local/bin/mediainfo"
    
Once you have an info object, you can start inspecting streams and general metadata.
    
    info.streams.count # 2
    info.audio?        # true
    info.video?        # true
    info.image?        # false
    
When inspecting specific types of streams, you have a couple general API options. The 
first approach assumes one stream of a given type, a common scenario in many video files, 
for example.
    
    info.video.count    # 1
    info.audio.count    # 1
    info.video.duration # 120 (seconds)
    
Sometimes you'll have more than one stream of a given type. Quicktime files can often 
contain artifacts like this from somebody editing a more 'normal' file.
    
    info = Mediainfo.new "funky.mov"
    
    info.video?            # true
    info.video.count       # 2
    info.video.duration    # raises SingleStreamAPIError !
    info.video[0].duration # 120
    info.video[1].duration # 10
    
For some more usage examples, please see the very reasonable test suite accompanying the source code 
for this library. It contains a bunch of relevant usage examples. More docs in the future.. contributions 
*very* welcome!

Moving on, REXML is used as the XML parser by default. If you'd like, you can 
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

## Requirements

This requires at least the following version of the Mediainfo CLI:
  
    MediaInfo Command line,
    MediaInfoLib - v0.7.25
  
Previous versions of this gem(<= 0.5.1) worked against v0.7.11, which did not 
generate XML output, and is no longer supported.

## Contributors

* Seth Thomas Rasmussen - [http://greatseth.com](http://greatseth.com)
* Peter Vandenberk      - [http://github.com/pvdb](http://github.com/pvdb)
* Ned Campion           - [http://github.com/nedcampion](http://github.com/nedcampion)
* Daniel Jagszent       - [http://github.com/d--j](http://github.com/d--j)
* Robert Mrasek         - [http://github.com/derobo](http://github.com/derobo)
