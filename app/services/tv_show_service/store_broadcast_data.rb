# frozen_string_literal: true

module TvShowService
  # Responsible for persisting a single TVMaze episode's data into the application's database.
  #
  # This class wraps the import of a `TvShow`, its `Distributor`, and the corresponding `Release`
  # inside a single transaction.
  #
  # It expects raw episode data (typically from the TVMaze API), parses it into a `TvMaze::Episode`
  # value object, and delegates persistence to upsert services.
  #
  # @example
  #   TvShowService::StoreBroadcastData.new(episode_hash).call
  #
  # @see TvMaze::Episode
  # @see TvShowService::UpsertShow
  # @see TvShowService::UpsertDistributor
  # @see TvShowService::UpsertRelease
  class StoreBroadcastData
    # @param episode_data [Hash] Raw episode data from TVMaze API.
    def initialize(episode_data)
      @episode = TvMaze::Episode.new(episode_data)
    end

    attr_reader :episode

    # Executes the import process for a single episode.
    #
    # Persists the TvShow, Distributor, and Release records if valid.
    # Logs errors if anything fails at the ActiveRecord level.
    #
    # @return [void]
    def call
      return unless episode.show

      ActiveRecord::Base.transaction do
        UpsertRelease.call(episode, upsert_show, upsert_distributor)
      end
    rescue ActiveRecord::ActiveRecordError => e
      Rails.logger.error(
        message: 'Episode import failure',
        episode_id: episode.id,
        error: e.message
      )
    end

    # Upserts the show associated with the episode.
    #
    # @return [TvShow] The persisted or updated TvShow record.
    def upsert_show
      UpsertShow.call(episode.show)
    end

    # Upserts the distributor (network/webChannel) for the episode's show.
    #
    # @return [Distributor, nil] The persisted Distributor or nil if not present.
    def upsert_distributor
      UpsertDistributor.call(episode.show.distributor)
    end
  end
end
