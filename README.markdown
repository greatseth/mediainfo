# Mediainfo

Mediainfo is a class wrapping [the mediainfo CLI](http://mediainfo.sourceforge.net).

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

## Contributors

* Seth Thomas Rasmussen - [http://greatseth.com](http://greatseth.com)
