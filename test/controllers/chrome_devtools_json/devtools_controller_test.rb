require "test_helper"

module ChromeDevtoolsJson
  class DevtoolsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @uuid_path = Rails.root.join("tmp", "chrome_devtools_uuid")
      File.delete(@uuid_path) if File.exist?(@uuid_path)
    end

    test "should get devtools json" do
      get chrome_devtools_json_path
      assert_response :success

      # Validate JSON structure
      json = JSON.parse(response.body)
      assert_not_nil json["workspace"]
      assert_equal Rails.root.to_s, json["workspace"]["root"]
      assert_not_nil json["workspace"]["uuid"]
    end

    test "should generate and persist uuid" do
      # First request - generates UUID
      get chrome_devtools_json_path
      json1 = JSON.parse(response.body)
      uuid1 = json1["workspace"]["uuid"]

      assert File.exist?(@uuid_path)
      assert_equal uuid1, File.read(@uuid_path).strip

      # Second request - should use persisted UUID
      get chrome_devtools_json_path
      json2 = JSON.parse(response.body)
      uuid2 = json2["workspace"]["uuid"]

      assert_equal uuid1, uuid2
    end
  end
end
