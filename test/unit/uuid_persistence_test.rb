require "test_helper"

module ChromeDevtoolsJson
  class UuidPersistenceTest < ActiveSupport::TestCase
    setup do
      @controller = ChromeDevtoolsJson::DevtoolsController.new
      @uuid_path = Rails.root.join("tmp", "chrome_devtools_uuid")
      File.delete(@uuid_path) if File.exist?(@uuid_path)
    end

    test "uuid method returns a valid UUID" do
      uuid = @controller.send(:uuid)
      assert_match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i, uuid)
    end

    test "persist_uuid creates and saves a UUID" do
      uuid = @controller.send(:persist_uuid, @uuid_path)

      assert File.exist?(@uuid_path)
      assert_equal uuid, File.read(@uuid_path).strip
      assert_match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i, uuid)
    end

    test "uuid method uses existing UUID if available" do
      # Create a known UUID
      known_uuid = "11111111-2222-3333-4444-555555555555"
      File.write(@uuid_path, known_uuid)

      # Check that the method returns the existing UUID
      assert_equal known_uuid, @controller.send(:uuid)
    end
  end
end
