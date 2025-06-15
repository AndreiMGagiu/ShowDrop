# frozen_string_literal: true

# TvShowService::UpsertDistributor handles the upserting of a Distributor record
# based on data from a `TvMaze::Distributor` value object.
#
# This ensures idempotent creation or updating of a distributor by name,
# avoiding duplicates and aligning with the TVMaze data source.
#
# Example:
#   distributor_vo = TvMaze::Distributor.new(raw_hash)
#   distributor_record = TvShowService::UpsertDistributor.call(distributor_vo)
#
# Returns the matching or newly created Distributor record.
module TvShowService
  class UpsertDistributor
    # Upserts a distributor into the database using unique name constraint.
    #
    # @param distributor [TvMaze::Distributor, nil] The distributor value object.
    # @return [Distributor, nil] The persisted ActiveRecord Distributor or nil if none given.
    def self.call(distributor)
      return unless distributor

      Distributor.upsert(
        {
          name: distributor.name,
          country: distributor.country,
          kind: distributor.kind
        },
        unique_by: :name
      )

      Distributor.find_by(name: distributor.name)
    end
  end
end
