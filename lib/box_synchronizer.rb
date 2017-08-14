module DiscourseBackupToBox
  class BoxSynchronizer < Synchronizer

    def initialize(backup)
      super(backup)
      @api_key = SiteSetting.discourse_sync_to_box_api_key
      @enabled = SiteSetting.discourse_sync_to_box_enabled
    end

    def box
      @box ||= Boxr::Client.new(@api_key)
    end

    def can_sync?
      @enabled && @api_key.present? && backup.present?
    end

    def delete_old_files
    end

    protected

    def perform_sync
      folder_name = Discourse.current_hostname
      box_folder = box.create_folder(folder_name, 0) # parent folder ID = 0
      full_path = backup.path
      file = box.upload_file(full_path, box_folder)
    end

    def upload_unique_files
    end

    def add_to_folder
    end

    def create_folder
    end

  end
end
