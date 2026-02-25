# Start Barnes for single-process dynos so metrics are reported when
# Puma is not running clustered workers. When running multiple Puma
# workers Barnes should be started inside `on_worker_boot` (see
# `config/puma.rb`).

if defined?(Barnes)
  web_concurrency = ENV.fetch("WEB_CONCURRENCY", "1").to_i

  # Configure Barnes if you want to customize interval or panels.
  # Barnes.configure do |c|
  #   c.interval = (ENV["BARNES_INTERVAL"] || 10).to_i
  # end

  if web_concurrency <= 1 && Barnes.respond_to?(:start)
    begin
      Barnes.start
    rescue => e
      Rails.logger.warn "Barnes.start failed during initialization: #{e.class}: #{e.message}"
    end
  end
end
