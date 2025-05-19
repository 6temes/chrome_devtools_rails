module ChromeDevtoolsRails
  class DevtoolsController < ActionController::Base
    def show
      render json: {
        workspace: {
          root: Rails.root.to_s,
          uuid: uuid
        }
      }
    end

    private

    def uuid
      path = Rails.root.join("tmp", "chrome_devtools_uuid")
      File.exist?(path) ? File.read(path).strip : persist_uuid(path)
    end

    def persist_uuid(path)
      uuid = SecureRandom.uuid
      File.write(path, uuid)
      uuid
    end
  end
end
