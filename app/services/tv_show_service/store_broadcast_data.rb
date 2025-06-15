# frozen_string_literal: true

# TvShowService::StoreBroadcastData is responsible for persisting a single
# TVMaze episode's data into the application's database. It wraps the import
# of a `TvShow`, its `Distributor`, and the corresponding `Release` inside
# a single transaction.
#
# This service expects raw episode data (typically from the TVMaze API),
# parses it via a `TvMaze::Episode` value object, and upserts the relevant
# records using dedicated upsert services.
#
# Example:
#   TvShowService::StoreBroadcastData.new(episode_hash).call
module TvShowService
  class StoreBroadcastData
    # @param episode_data [Hash] Raw episode data from TVMaze API.
    def initialize(episode_data)
      @episode = TvMaze::Episode.new(episode_data)
    end

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

    # @return [TvMaze::Episode] The wrapped episode value object.
    attr_reader :episode
  end
end
