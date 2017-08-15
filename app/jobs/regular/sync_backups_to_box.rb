module Jobs
  class SyncBackupsToBox < ::Jobs::Base

    sidekiq_options queue: 'low'

    def execute(arg)
      backups = Backup.all.take(SiteSetting.discourse_sync_to_box_quantity)
      backups.each {|backup| DiscourseBackupToBox::BoxSynchronizer.new(backup).sync}
      DiscourseBackupToBox::BoxSynchronizer.new(backups).delete_old_files
    end
  end
end
