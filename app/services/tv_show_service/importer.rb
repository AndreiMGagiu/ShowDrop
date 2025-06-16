# frozen_string_literal: true

module TvShowService
  # Coordinates the import of upcoming TV show episodes from the TVMaze API.
  #
  # This service uses `TvMazeClient` to fetch data for a given date range and
  # persists the data using `TvShowService::StoreBroadcastData`.
  #
  # It supports API rate-limiting and allows configurable import duration and
  # pluggable API client (for testing/mocking purposes).
  #
  # @example Import the next 30 days of episodes:
  #   TvShowService::Importer.new(days: 30).call
  #
  # @see TvMazeClient
  # @see TvShowService::StoreBroadcastData
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

    # Computes the range of dates to import.
    #
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
    # @param date [Date] The date to fetch episodes for.
    # @return [Array<Hash>] An array of episode hashes.
    def tv_show_episodes(date)
      client.fetch_episodes(date)
    end
  end
end
