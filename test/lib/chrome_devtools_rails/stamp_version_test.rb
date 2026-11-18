require "test_helper"
require "open3"
require "tmpdir"

module ChromeDevtoolsRails
  class StampVersionTest < ActiveSupport::TestCase
    SCRIPT = File.expand_path("../../../bin/stamp-version", __dir__)
    VERSION_FILE = File.expand_path("../../../lib/chrome_devtools_rails/version.rb", __dir__)

    setup do
      @dir = Dir.mktmpdir
      @target = File.join(@dir, "version.rb")
      FileUtils.cp VERSION_FILE, @target
    end

    teardown do
      FileUtils.remove_entry @dir
    end

    test "the unreleased placeholder satisfies the >= 0 requirement Bundler gives a git source" do
      assert_operator Gem::Version.new(VERSION), :>=, Gem::Version.new("0")
    end

    test "stamps the version into the real version file" do
      _, status = stamp("1.2.3")

      assert status.success?
      assert_equal "1.2.3", loaded_version
    end

    test "rejects a version that does not survive a Gem::Version round trip" do
      [ "abc", "", "1.2.3-rc1" ].each do |version|
        original = File.read(@target)
        stderr, status = stamp(version)

        assert_not status.success?, "expected #{version.inspect} to be rejected"
        assert_match "not a release version", stderr
        assert_equal original, File.read(@target)
      end
    end

    test "rejects a file with no VERSION literal" do
      File.write @target, "module ChromeDevtoolsRails\nend\n"

      stderr, status = stamp("1.2.3")

      assert_not status.success?
      assert_match "VERSION", stderr
      assert_equal "module ChromeDevtoolsRails\nend\n", File.read(@target)
    end

    test "rejects a file whose placeholder is followed by a second VERSION assignment" do
      [ "=begin\n  VERSION = \"9.9.9\"\n=end", "  VERSION = \"9.9.9\" # release version" ].each do |second|
        File.write @target, "module ChromeDevtoolsRails\n  VERSION = \"0.0.1.dev\"\n#{second}\nend\n"
        original = File.binread(@target)

        _, status = stamp("1.2.3")

        assert_not status.success?, "expected a file with #{second.inspect} to be rejected"
        assert_equal original, File.binread(@target)
      end
    end

    private
      def stamp(version)
        _, stderr, status = Open3.capture3(RbConfig.ruby, SCRIPT, version, @target)
        [ stderr, status ]
      end

      # Loaded in a subprocess so the suite's own ChromeDevtoolsRails::VERSION is never redefined.
      def loaded_version
        stdout, stderr, status = Open3.capture3(RbConfig.ruby, "-e", "load ARGV[0]; print ChromeDevtoolsRails::VERSION", @target)
        assert status.success?, stderr
        stdout
      end
  end
end
