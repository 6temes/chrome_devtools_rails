require "test_helper"

module ChromeDevtoolsRails
  class DeprecationTest < ActiveSupport::TestCase
    test "superseded_by_rails? is true on the native-support version and later" do
      Rails.stubs(:gem_version).returns(Gem::Version.new("8.2.0"))
      assert ChromeDevtoolsRails.superseded_by_rails?

      Rails.stubs(:gem_version).returns(Gem::Version.new("9.0.0"))
      assert ChromeDevtoolsRails.superseded_by_rails?
    end

    test "superseded_by_rails? is false before native support" do
      Rails.stubs(:gem_version).returns(Gem::Version.new("8.1.3"))
      assert_not ChromeDevtoolsRails.superseded_by_rails?
    end

    test "warn_if_superseded warns when Rails serves the endpoint natively" do
      Rails.stubs(:gem_version).returns(Gem::Version.new("8.2.0"))
      assert_deprecated(ChromeDevtoolsRails.deprecator) do
        ChromeDevtoolsRails.warn_if_superseded
      end
    end

    test "warn_if_superseded stays quiet before native support" do
      Rails.stubs(:gem_version).returns(Gem::Version.new("8.1.3"))
      assert_not_deprecated(ChromeDevtoolsRails.deprecator) do
        ChromeDevtoolsRails.warn_if_superseded
      end
    end
  end
end
