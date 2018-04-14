# -*- encoding: utf-8 -*-

require 'mediainfo/version'

Gem::Specification.new do |s|
  s.name = %q{mediainfo}
  s.version = Mediainfo::VERSION
  s.required_rubygems_version = Gem::Requirement.new('>= 1.2') if s.respond_to? :required_rubygems_version=
  s.authors = ['Seth Thomas Rasmussen']
  s.date = %q{2010-04-06}
  s.description = %q{Mediainfo is a class wrapping the mediainfo CLI (http://mediainfo.sourceforge.net)}
  s.email = %q{sethrasmussen@gmail.com}
  s.homepage = %q{https://github.com/greatseth/mediainfo}
  s.rdoc_options = ['--line-numbers', '--inline-source', '--title', 'Mediainfo', '--main']
  s.require_paths = ['lib']
  s.rubyforge_project = %q{mediainfo}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Mediainfo is a class wrapping the mediainfo CLI (http://mediainfo.sourceforge.net)}
  s.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  s.add_development_dependency('echoe')
  s.add_development_dependency('mocha')

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
