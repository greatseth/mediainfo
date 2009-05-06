require "test/unit"

module ActiveSupport
  class TestCase < Test::Unit::TestCase
    def self.test(desc, &block)
      define_method "test #{desc}", &block
    end
    
    def test_yourmom; end
  end
end

require "rubygems"
require "mocha"

$: << File.dirname(__FILE__) + "/../lib"
require "mediainfo"
