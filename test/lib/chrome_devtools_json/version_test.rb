require "test_helper"

module ChromeDevtoolsJson
  class VersionTest < ActiveSupport::TestCase
    test "has a version number" do
      assert_not_nil ChromeDevtoolsJson::VERSION
    end

    test "version follows semantic versioning format" do
      assert_match(/\A\d+\.\d+\.\d+\z/, ChromeDevtoolsJson::VERSION)
    end
  end
end
