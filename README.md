# MediaInfo [![Build Status](https://travis-ci.org/greatseth/mediainfo.svg?branch=master)](https://travis-ci.org/greatseth/mediainfo)

MediaInfo is a class wrapping [the mediainfo CLI](http://mediainfo.sourceforge.net).

## Installation

    $ gem install mediainfo

## Usage

- Versions > 1.3.0 support S3 URLs. See rspec test for example.

#### Parsing raw XML
    media_info = MediaInfo.from(File.open('iphone6+_video.mov.xml').read)
#### Handling a local file
    media_info = MediaInfo.from('~/Desktop/test.mov')
#### Handling a URL
    media_info = MediaInfo.from('http://techslides.com/demos/sample-videos/small.mp4')

Ensure mediainfo is installed and within your PATH. You can specify an alternate path for the mediainfo binary if needed:

    ENV['MEDIAINFO_PATH'] = "/usr/bin/mediainfo"

Once you have an MediaInfo object, you can start inspecting tracks:

    media_info.track_types       => ['general','video','audio']
    media_info.track_types.count => 3
    media_info.video?            => true
    media_info.image?            => nil
    media_info.image.filesize    => MethodNotFound exception

When inspecting specific types of tracks, you have a couple general API options. The
first approach assumes one track of a given type, a common scenario in many video files,
for example:

    media_info.video.count    => 1
    media_info.video.duration => 120 (seconds)

Sometimes you'll have more than one track of a given type:
 - The first track type name, or any track type with <ID>1</ID> will not contain '1'


        media_info.track_types                => ['general','video','video2','audio','other','other2']
        media_info.track_types.count          => 5
        media_info.video?                     => true
        media_info.image?                     => nil
        media_info.video.count                => 1
        media_info.video.duration             => 29855000
        media_info.video.display_aspect_ratio => 1.222
        media_info.other.count                => 2
        media_info.video2.duration            => 29855000

- Note that the above automatically converts MediaInfo Strings into Time, Integer, and Float objects:


        media_info.video.encoded_date.class         => Time
        media_info.video2.duration.class            => Integer
        media_info.video.display_aspect_ratio.class => Float

- Any track attribute name with "date" and matching /\d-/ will be converted using Time.parse:


        media_info.video.encoded_date => 2018-03-30 12:12:08 -0400
        media_info.video.customdate   => 2016-02-10 01:00:00 -0600

- .duration and .overall_duration will be returned as milliseconds AS LONG AS the Duration and Overall_Duration match one of the expected units (each separated by a space or not):
    - h (\<Duration>15h\</Duration>) (hour)
    - hour (\<Duration>15hour\</Duration>)
    - mn (\<Duration>15hour 6mn\</Duration>) (minute)
    - m (\<Duration>15hour 6m\</Duration>) (minute)
    - min (\<Duration>15hour 6min\</Duration>) (minute)
    - s (\<Duration>15hour 6min 59s\</Duration>) (second)
    - sec (\<Duration>15hour 6min 59sec\</Duration>) (second)
    - ms (\<Duration>15hour 6min 59sec 301ms\</Duration>) (milliseconds)
    - in the form of a Float (as for iphone mov files)
    - [Submit an issue to add more!](https://github.com/greatseth/mediainfo/issues)


            media_info.video.duration => 15164 (\<Duration>15s 164ms\</Duration>)
            media_info.video.duration => 36286 (\<Duration>36s 286ms\</Duration>)
            media_info.video.duration => 123456 (\<Duration>123.456\</Duration>)

- We standardize the naming of several Attributes:
    - You can review lib/attribute_standardization_rules.yml to see them all


            media_info.video.bit_rate => nil (\<Bit_rate>41.2 Mbps\</Bit_rate>)
            media_info.video.bitrate => "41.2 Mbps" (\<Bit_rate>41.2 Mbps\</Bit_rate>)
            media_info.general.filesize => "11.5 MiB" (\<File_size>11.5 MiB\</File_size>


In order to support all possible MediaInfo variations, you may see the following situation:

    media_info.track_types => ['general','video','video5','audio','other','other2']

The track type media_info.video5 is available, but no video2, 3, and 4. This is because the MediaInfo from the video has:

    <track type="Video">
        <ID>1</ID>
        ...
    <track type="Video">
        <ID>5</ID>
        ...

*The ID will take priority for labeling.* Else if no ID exists, you'll see consecutive numbering for duplicate tracks in the Media.

Any second level attributes are also available:

    MediaInfo.from('~/Desktop/test.mov').general.extra
    => #<MediaInfo::Tracks::Attributes::Extra:0x00007fa89f13aa98
     @com_apple_quicktime_creationdate=2018-03-30 08:12:08 -0400,
     @com_apple_quicktime_location_iso6709="+39.0286-077.3958+095.957/",
     @com_apple_quicktime_make="Apple",
     @com_apple_quicktime_model=0,
     @com_apple_quicktime_software=11.2>

REXML is used as the XML parser by default. If you'd like, you can
configure Mediainfo to use Nokogiri instead:

  * define the `MEDIAINFO_XML_PARSER` environment variable to be the
    name of the parser as you'd pass to a :gem or :require call.

    e.g. `export MEDIAINFO_XML_PARSER=nokogiri`

Once you've got an instance setup, you can call numerous methods to get
a variety of information about a file. Some attributes may be present
for some files where others are not, but any supported attribute
should at least return `nil`.


## Development

```shell
bundle install
irb -I ./lib -r mediainfo 
irb(main):002:0> ::MediaInfo.location
=> "/usr/local/bin/mediainfo"
```

### Testing

- 

```shell
bundle exec rspec 
```

## Requirements

* Gem version 1.0.0 has been tested on v18.03.1
* Gem versions < 1.0.0 require at least: MediaInfoLib v0.7.25
* Gem versions <= 0.5.1 worked against MediaInfoLib v0.7.11, which did not generate XML output, and is no longer supported.
