require 'net/http'
require 'json'
require 'forwardable'

load File.expand_path('../tasks/deploy_tracker.rake', __FILE__)

module DeployTracker
  #
  # DeployTracker capistrano mobule
  #
  class Capistrano
    extend Forwardable
    def_delegators :env, :fetch, :run_locally

    def initialize(env)
      @env = env
    end

    def run(action)
      return unless enabled?

      me = self
      run_locally { me.post(action, self) }
    end

    def post(action, backend)
      params = compile_params(action)
      backend_info(backend, params) if dry_run? || debug?

      unless dry_run?
        begin
          response = publish_deploy(params)
        rescue => e
          backend.warn('[deploy_tracker] Error publishing deploy info!')
          backend.warn("[deploy_tracker]   Error: #{e.inspect}")
        end

        api_failure(response) if response.code !~ /^2/
      end
    end

    def compile_params(action)
      {
        application: fetch(:display_name, fetch(:application)),
        project_url: fetch(:public_repo_url),
        stage: fetch(:stage),
        branch: fetch(:branch),
        commit_hash: fetch(:current_revision, 'deadbeef'),
        deployer: fetch(:local_user),
        action: action
      }
    end
    private :compile_params

    def dry_run?
      if ::Capistrano::Configuration.respond_to?(:dry_run?)
        ::Capistrano::Configuration.dry_run?
      else
        ::Capistrano::Configuration.env.send(:config)[:sshkit_backend] == SSHKit::Backend::Printer
      end
    end
    private :dry_run?

    def backend_info(backend, params)
      backend.info('[deploy_tracker] Deploy Tracker:')
      backend.info("[deploy_tracker]   Application: #{params[:application]}")
      backend.info("[deploy_tracker]   Project URL: #{params[:project_url]}")
      backend.info("[deploy_tracker]   Stage: #{params[:stage]}")
      backend.info("[deploy_tracker]   Branch: #{params[:branch]}")
      backend.info("[deploy_tracker]   Commit Hash: #{params[:commit_hash]}")
      backend.info("[deploy_tracker]   Deployer: #{params[:deployer]}")
    end
    private :backend_info

    def api_failure(response)
      warn('[DeployTracker] API Failure!')
      warn("[DeployTracker]   URI: #{response.uri}")
      warn("[DeployTracker]   Code: #{response.code}")
      warn("[DeployTracker]   Message: #{response.message}")
      warn("[DeployTracker]   Body: #{response.body}") if response.message != response.body && response.body !~ /<html/
    end
    private :api_failure

    def debug?
      fetch(:deploy_tracker_debug)
    end
    private :debug?

    def enabled?
      fetch(:deploy_tracker_enabled)
    end
    private :enabled?

    def api_token
      fetch(:deploy_tracker_api_token)
    end
    private :api_token

    def api_url
      fetch(:deploy_tracker_api_url)
    end
    private :api_url

    def publish_deploy(params)
      uri = URI("#{api_url}/publish?auth_token=#{api_token}")
      Net::HTTP.post_form(uri, params)
    end
    private :publish_deploy
  end
end
