require "test_helper"

module ChromeDevtoolsRails
  class VersionTest < ActiveSupport::TestCase
    test "has a version number" do
      assert_not_nil ChromeDevtoolsRails::VERSION
    end

    test "version follows semantic versioning format" do
      assert_match(/\A\d+\.\d+\.\d+\z/, ChromeDevtoolsRails::VERSION)
    end
  end
end
