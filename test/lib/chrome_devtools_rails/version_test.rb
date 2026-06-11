require "test_helper"

module ChromeDevtoolsRails
  class VersionTest < ActiveSupport::TestCase
    test "has a version number" do
      assert_not_nil ChromeDevtoolsRails::VERSION
    end

    test "version is a valid gem version" do
      assert Gem::Version.correct?(ChromeDevtoolsRails::VERSION)
    end
  end
end
