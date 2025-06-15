# frozen_string_literal: true

# TvShowService::UpsertRelease is responsible for upserting a Release record
# using structured data from the TVMaze API wrapped in value objects.
#
# This service ensures the `Release` for a given episode is either created
# or updated based on the unique episode ID.
#
# Example:
#   TvShowService::UpsertRelease.call(episode_vo, tv_show_record, distributor_record)
#
# @note This assumes all inputs are valid and present. Callers should validate before.
module TvShowService
  class UpsertRelease
    # Upserts a Release record using episode, tv show, and distributor data.
    #
    # @param episode [TvMaze::Episode] The value object containing episode details.
    # @param show [TvShow] The associated TvShow ActiveRecord model.
    # @param distributor [Distributor] The associated Distributor ActiveRecord model.
    # @return [void]
    def self.call(episode, show, distributor)
      Release.upsert(
        {
          episode_id: episode.id,
          tv_show_id: show.id,
          distributor_id: distributor.id,
          episode_name: episode.name,
          airdate: episode.airdate,
          airstamp: episode.airstamp,
          runtime: episode.runtime,
          season: episode.season,
          number: episode.number
        },
        unique_by: :episode_id
      )
    end
  end
end
