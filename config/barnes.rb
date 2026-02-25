# config/initializers/barnes.rb
if defined?(Barnes)
  web_concurrency = ENV.fetch("WEB_CONCURRENCY", "1").to_i

  # Configure Barnes panels (optional) or rely on defaults
  # Barnes.configure { |c| ... } # if you want custom options

  # Start Barnes for single-process dynos (when Puma workers are not used)
  if web_concurrency <= 1 && Barnes.respond_to?(:start)
    begin
      Barnes.start
    rescue => e
      Rails.logger.warn "Barnes.start failed during initialization: #{e.message}"
    end
  end
end