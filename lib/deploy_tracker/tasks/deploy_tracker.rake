namespace :deploy_tracker do
  namespace :deploy do
    desc 'Notify about finished deploy'
    task :finished do
      DeployTracker::Capistrano.new(self).run(:success)
    end

    desc 'Notify about finished rollback'
    task :reverted do
      DeployTracker::Capistrano.new(self).run(:rollback)
    end

    desc 'Notify about failed deploy'
    task :failed do
      DeployTracker::Capistrano.new(self).run(:failed)
    end

    desc 'Test deploy tracker integration'
    task test: %i(finished reverted failed) do
      # all tasks run as dependencies
    end
  end
end

after  'deploy:finishing',          'deploy_tracker:deploy:finished'
after  'deploy:finishing_rollback', 'deploy_tracker:deploy:reverted'
after  'deploy:failed',             'deploy_tracker:deploy:failed'

namespace :load do
  task :defaults do
    set :deploy_tracker_api_token, -> { ENV['DEPLOY_TRACKER_API_TOKEN'] }
    set :deploy_tracker_api_url, -> { ENV['DEPLOY_TRACKER_API_URL'] }
    set :deploy_tracker_debug, -> { ENV['DEPLOY_TRACKER_DEBUG'] }
    set :deploy_tracker_enabled, -> { true }
  end
end
