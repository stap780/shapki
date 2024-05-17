require "sidekiq-scheduler"

class DeleteUnattachedBlobsScheduler
  include Sidekiq::Worker

  def perform
    Rails.application.load_tasks
    Rake::Task["file:delete_unattached_blobs_every_day"].invoke
  end
end

