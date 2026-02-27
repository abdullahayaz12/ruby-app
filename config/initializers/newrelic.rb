module PumaMetrics
  def self.register_puma_stats
    # Register a custom metric for Puma thread pool stats
    if defined?(Puma::Server)
      @thread_pool_stats = {
        pool_capacity: 0,
        max_threads: 0,
        running: 0,
        backlog: 0
      }
    end
  end

  def self.collect_puma_stats
    if defined?(Puma) && ENV['RAILS_ENV'] != 'test'
      begin
        # Access Puma's thread pool if available
        if Object.const_defined?(:Puma) && Puma.const_defined?(:Server)
          # Try to get stats from the current Puma server instance
          stats = {
            timestamp: Time.now.to_i,
            pool_capacity: ENV.fetch('RAILS_MAX_THREADS', 3).to_i,
            max_threads: ENV.fetch('RAILS_MAX_THREADS', 3).to_i,
            running: 'N/A'
          }
          
          NewRelic::Agent.record_custom_event('PumaStats', stats)
        end
      rescue => e
        # Fail silently if Puma stats unavailable
      end
    end
  end
end

# New Relic agent initializes automatically when the gem is required
# No explicit startup needed for newrelic_rpm gem

# Register Puma metrics
PumaMetrics.register_puma_stats

# Schedule periodic collection of Puma stats
if defined?(ActiveSupport)
  ActiveSupport::Notifications.subscribe('process_action.action_controller') do
    PumaMetrics.collect_puma_stats
  end
end

