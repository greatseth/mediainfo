# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{mediainfo}
  s.version = "0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Seth Thomas Rasmussen"]
  s.date = %q{2009-07-20}
  s.description = %q{}
  s.email = %q{sethrasmussen@gmail.com}
  s.extra_rdoc_files = ["lib/mediainfo/attr_readers.rb", "lib/mediainfo/string.rb", "lib/mediainfo.rb", "LICENSE", "README.markdown"]
  s.files = ["Changelog", "lib/mediainfo/attr_readers.rb", "lib/mediainfo/string.rb", "lib/mediainfo.rb", "LICENSE", "Manifest", "mediainfo.gemspec", "Rakefile", "README.markdown", "test/mediainfo_awaywego_encoded_test.rb", "test/mediainfo_awaywego_test.rb", "test/mediainfo_dinner_test.rb", "test/mediainfo_hats_test.rb", "test/mediainfo_string_test.rb", "test/mediainfo_test.rb", "test/mediainfo_vimeo_test.rb", "test/mediainfo_vimeoimage_test.rb", "test/test_helper.rb"]
  s.homepage = %q{http://greatseth.com}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Mediainfo", "--main", "README.markdown"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{mediainfo}
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{}
  s.test_files = ["test/mediainfo_awaywego_encoded_test.rb", "test/mediainfo_awaywego_test.rb", "test/mediainfo_dinner_test.rb", "test/mediainfo_hats_test.rb", "test/mediainfo_string_test.rb", "test/mediainfo_test.rb", "test/mediainfo_vimeo_test.rb", "test/mediainfo_vimeoimage_test.rb", "test/test_helper.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
