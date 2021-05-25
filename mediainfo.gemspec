# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mediainfo/version'

Gem::Specification.new do |s|
  s.name = %q{mediainfo}
  s.version = MediaInfo::VERSION
  s.licenses    = ['MIT']
  s.required_rubygems_version = Gem::Requirement.new('>= 1.2') if s.respond_to? :required_rubygems_version=
  s.authors = ['Seth Thomas Rasmussen']
  s.description = %q{MediaInfo is a class wrapping the mediainfo CLI (http://mediainfo.sourceforge.net) that standardizes attributes/methods and also converts most values into something Ruby can understand.}
  s.email = %q{sethrasmussen@gmail.com}
  s.homepage = %q{https://github.com/greatseth/mediainfo}
  s.rdoc_options = ['--line-numbers', '--inline-source', '--title', 'Mediainfo', '--main']
  s.require_paths = ['lib']
  s.summary = %q{MediaInfo is a class wrapping the mediainfo CLI (http://mediainfo.sourceforge.net)}
  s.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  s.add_dependency 'rexml'

  s.add_development_dependency 'bundler', '~> 2'
  s.add_development_dependency 'rake', '~> 12.3'
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'nokogiri', '>= 1.8', '< 2.0' # Ability to parse XML response # Optional and should be included by user in their own gemfile
  s.add_development_dependency 'aws-sdk-s3'
  s.add_development_dependency 'pry'

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3
  end
end
