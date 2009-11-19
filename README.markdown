# Mediainfo

Mediainfo is a class wrapping [the mediainfo CLI](http://mediainfo.sourceforge.net).

## Installation
  
  $ gem install mediainfo -s http://gemcutter.org
  
## Usage
  
    info = Mediainfo.new "/path/to/file"
  
That will issue the system call to `mediainfo` and parse the output. 
From there, you can call numerous methods to get a variety of information 
about a file. Some attributes may be present for some files where others 
are not.

For a list of all possible attributes supported:
  
    Mediainfo.supported_attributes
  
In addition to the stock arguments provided by parsing `mediainfo` output, 
some convenience methods and added behavior is added.

Mediainfo is inspired by RVideo::Inspector, part of the rvideo gem. 
The rvideo inspector is based on output from ffmpeg which is not 
intended to be machine parseable. I spent a little while chasing 
the ffmpeg development team, and decided finally that perhaps other 
tools were better. As such, some of the API for Mediainfo is straight 
from RVideo::Inspector. Some is not. Just saying.

## Requirements

This library is compatible with:
  
  MediaInfo Command line, 
  MediaInfoLib - v0.7.11
  
to the extent that is documented in the tests.

## Contributors

* Seth Thomas Rasmussen - [http://greatseth.com](http://greatseth.com)
* Peter Vandenberk - [http://github.com/pvdb](http://github.com/pvdb)
