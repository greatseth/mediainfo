# MediaInfo

MediaInfo is a class wrapping [the mediainfo CLI](http://mediainfo.sourceforge.net).

## Installation
    
    $ gem install mediainfo
    
## Usage

#### Parsing raw XML
    media_info = MediaInfo.obtain(File.open('iphone6+_video.mov.xml').read)
#### Handling a local file
    media_info = MediaInfo.obtain('~/Desktop/test.mov')
#### Handling a URL
    media_info = MediaInfo.obtain('http://techslides.com/demos/sample-videos/small.mp4')

You can specify an alternate path for the MediaInfo Binary:
    
    ENV['MEDIAINFO_PATH'] = "/opt/local/bin/mediainfo"
    
Once you have an MediaInfo object, you can start inspecting tracks:
    
    media_info.track_types       # ['general','video','audio']
    media_info.track_types.count # 3
    media_info.video?            # true
    media_info.image?            # nil
    
When inspecting specific types of tracks, you have a couple general API options. The 
first approach assumes one track of a given type, a common scenario in many video files, 
for example:
    
    media_info.video.count    # 1
    media_info.video.duration # 120 (seconds)
    
Sometimes you'll have more than one track of a given type. _The first track type, or any track type with <ID>1</ID> will not contain '1':_
    
    media_info.track_types       # ['general','video','video2','audio','other','other2']
    media_info.track_types.count # 5
    media_info.video?            # true
    media_info.image?            # nil
    media_info.video.count       # 1
    media_info.video.duration    # 120
    media_info.other.count       # 2
    media_info.video2.duration   # 10
    
In order to support all possible MediaInfo variations, you'll potentially see the following:

    media_info.track_types # ['general','video','video5','audio','other','other2']
    
The track type media_info.video5 is available. But only because the MediaInfo from the video has:

    <track type="Video">
        <ID>1</ID>...
    <track type="Video">
        <ID>5</ID>...

REXML is used as the XML parser by default. If you'd like, you can 
configure Mediainfo to use Hpricot or Nokogiri instead using one of 
the following approaches:

  * define the `MEDIAINFO_XML_PARSER` environment variable to be the 
    name of the parser as you'd pass to a :gem or :require call. 
    
    e.g. `export MEDIAINFO_XML_PARSER=nokogiri`
    
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
* Nathan Pierce         - [http://github.com/NorseGaud](http://github.com/NorseGaud)