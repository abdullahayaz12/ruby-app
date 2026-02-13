# Bullet Filter - Only report N+1 queries for changed files
# This module filters Bullet notifications to only show issues in changed files

module BulletFilter
  class ChangedFilesFilter
    def initialize(changed_files = [])
      @changed_files = Array(changed_files).map { |f| File.expand_path(f) }
      @violations = []
    end

    def filter_notification(notification)
      # Check if the notification's stacktrace includes any changed files
      return false if @changed_files.empty?

      # Get the backtrace from the notification
      backtrace = notification.backtrace || []
      
      # Check if any frame in the backtrace matches a changed file
      backtrace.each do |frame|
        file_path = extract_file_path(frame)
        next unless file_path
        
        full_path = File.expand_path(file_path)
        if @changed_files.any? { |changed| full_path.include?(changed) || changed.include?(full_path) }
          return true
        end
      end

      false
    end

    private

    def extract_file_path(frame)
      # Extract file path from stack frame
      # Format: "/path/to/file.rb:123:in `method_name'"
      match = frame.match(/^(.+?):\d+/)
      match ? match[1] : nil
    end
  end

  # Custom Bullet notification handler that filters by changed files
  class FilteredNotificationHandler
    def initialize(changed_files = [])
      @filter = ChangedFilesFilter.new(changed_files)
      @filtered_count = 0
      @total_count = 0
    end

    def call(notification)
      @total_count += 1
      
      # Filter notification based on changed files
      if @filter.changed_files.empty? || @filter.filter_notification(notification)
        # Show notification
        Bullet::Notification::Base.logger.call(notification)
        true
      else
        # Skip notification (file not in changed files)
        @filtered_count += 1
        false
      end
    end

    def stats
      {
        total: @total_count,
        filtered: @filtered_count,
        shown: @total_count - @filtered_count
      }
    end
  end
end
