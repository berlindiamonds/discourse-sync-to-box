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
      delete_from_folder
      delete_from_trash
    end

    def delete_from_folder
      folder_name = Discourse.current_hostname
      box_folder = box.folder_from_path("/#{folder_name}").id
      box_files = box.folder_items(box_folder).reverse!
      keep = box_files.take(SiteSetting.discourse_sync_to_box_quantity)
      old_files = box_files - keep
      old_files.each {|f| box.delete_file(f)}
    end

    def delete_from_trash
      box.trash.each do |f|
        if f.name.include? "discourse"
          box.delete_trashed_file(f)
        else
          nil
        end
      end
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
      box_files = box.folder_items(box_folder).map(&:name)
      ([backup].map(&:filename) - box_files).each do |f|
        if f.present?
          full_path = backup.path
          box.upload_file(full_path, box_folder)
        end
      end
    end

  end
end
