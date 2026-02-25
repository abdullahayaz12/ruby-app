# threads_count = ENV.fetch("RAILS_MAX_THREADS", 3)
# threads threads_count, threads_count

# # Processes count, allows better CPU utilization when executing Ruby code.
# # Recommended to always run in at least one process so `rack-timeout` RACK_TERM_ON_TIMEOUT=1 can be used
# # https://devcenter.heroku.com/articles/h12-request-timeout-in-ruby-mri
# workers(ENV.fetch('WEB_CONCURRENCY') { 2 })

# # Support IPv6 by binding to host `::` in production instead of `0.0.0.0` and `::1` instead of `127.0.0.1` in development.
# host = ENV.fetch("RAILS_ENV") { "development" } == "production" ? "::" : "::1"

# # PORT environment variable is set by Heroku in production.
# port(ENV.fetch("PORT") { 3000 }, host)

# # Allow puma to be restarted by `bin/rails restart` command.
# plugin :tmp_restart

# # Run the Solid Queue supervisor inside of Puma for single-server deployments
# plugin :solid_queue if ENV["SOLID_QUEUE_IN_PUMA"]

# # Specify the PID file. Defaults to tmp/pids/server.pid in development.
# # In other environments, only set the PID file if requested.
# pidfile ENV["PIDFILE"] if ENV["PIDFILE"]

threads_count = ENV.fetch("RAILS_MAX_THREADS", 3).to_i
threads threads_count, threads_count
workers Integer(ENV.fetch("WEB_CONCURRENCY") { 2 })

on_worker_boot do
  # Re-establish AR connection in worker
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)

  # Start Barnes inside the worker (after Rails is loaded) so Puma.stats is available
  begin
    require 'barnes'
    Barnes.start if defined?(Barnes) && Barnes.respond_to?(:start)
  rescue LoadError => e
    warn "Barnes not available in worker: #{e.message}"
  rescue => e
    warn "Barnes.start failed in on_worker_boot: #{e.class}: #{e.message}"
  end
end