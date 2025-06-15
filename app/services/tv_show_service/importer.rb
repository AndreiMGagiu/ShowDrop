# frozen_string_literal: true

# TvShowService::Importer coordinates the import of upcoming TV show episodes
# from the TVMaze API over a date range. It uses the `TvMazeClient` to fetch
# data and delegates persistence to `StoreBroadcastData`.
#
# Example:
#   TvShowService::Importer.new(days: 30).call
#
# Options:
# - Specify `days` to control the range of future dates (default: 90)
# - Inject a custom client (e.g. mock or stubbed version for testing)
module TvShowService
  class Importer
    DEFAULT_DAYS = 90
    RATE_LIMIT_SLEEP = 0.5

    # @param days [Integer] Number of future days to import from today.
    # @param client [TvMazeClient] API client responsible for fetching episodes.
    def initialize(days: DEFAULT_DAYS, client: TvMazeClient.new)
      @days = days
      @client = client
    end

    attr_reader :days, :client

    # Executes the import by looping over each date, fetching episodes, and
    # delegating their persistence to `StoreBroadcastData`.
    #
    # Respects API rate limits via sleep.
    #
    # @return [void]
    def call
      import_range.each do |date|
        import_upcoming_releases(date)
        sleep RATE_LIMIT_SLEEP
      end

      Rails.logger.info(
        message: "TVMaze import complete",
        imported_days: days
      )
    end

    private

    # @return [Array<Date>] An array of dates from today to today + days.
    def import_range
      (0...days).map { |offset| Date.current + offset.days }
    end

    # Imports all episodes for a given date.
    #
    # @param date [Date] The specific date to import.
    # @return [void]
    def import_upcoming_releases(date)
      tv_show_episodes(date).each do |episode|
        StoreBroadcastData.new(episode).call
      end
    end

    # Fetches raw episode data from the client.
    #
    # @param date [Date]
    # @return [Array<Hash>] An array of episode hashes.
    def tv_show_episodes(date)
      client.fetch_episodes(date)
    end
  end
end
