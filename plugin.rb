# name: discourse-sync-to-box
# about: -
# version: 0.1
# authors: Jen
# url: https://github.com/berlindiamonds/discourse-sync-to-box

gem 'httpclient', '2.8.3', {require: false}
gem 'boxr', '1.4.0'

enabled_site_setting :discourse_sync_to_box_enabled

after_initialize do
  load File.expand_path("../app/jobs/regular/sync_backups_to_box.rb", __FILE__)
  load File.expand_path("../lib/box_synchronizer.rb", __FILE__)

  DiscourseEvent.on(:backup_created) do
    Jobs.enqueue(:sync_backups_to_box)
  end
end
