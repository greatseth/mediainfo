require "test/unit"

require "rubygems"
require "mocha"
require "mocha/test_unit"
begin; require "redgreen"; rescue LoadError; end

module ActiveSupport
  class TestCase < Test::Unit::TestCase
    def self.test(desc, &block)
      define_method "test #{desc}", &block
    end
    
    def test_yourmom; end
  end
end


$: << File.dirname(__FILE__) + "/../lib"
require "mediainfo"
