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
      folder_name = Discourse.current_hostname
      box_folder = box.folder_from_path("/#{folder_name}").id
      box_files = box.folder_items(box_folder)
      keep = box_files.take(SiteSetting.discourse_sync_to_box_quantity)
      trash = box_files - keep
      trash.each {|f| box.delete_file(f)}
    end

    protected

    def perform_sync
      folder_name = Discourse.current_hostname
      begin
        box.create_folder(folder_name, 0)
      rescue
        # folder already exists
      end
      box_folder = box.folder_from_path("/#{folder_name}").id
      upload_unique_files(box_folder)
    end

    def upload_unique_files(box_folder)
      box_files = box.folder_items(box_folder)
      ([backup] - box_files).each do |f|
        if f.present?
          full_path = f.path
          box.upload_file(full_path, box_folder)
        end
      end
    end

  end
end
