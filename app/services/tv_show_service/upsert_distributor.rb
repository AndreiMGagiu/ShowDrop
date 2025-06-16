# frozen_string_literal: true

module TvShowService
  # Handles the upserting of a Distributor record based on data
  # from a `TvMaze::Distributor` value object.
  #
  # This ensures idempotent creation or updating of a distributor by name,
  # avoiding duplicates and aligning with the TVMaze data source.
  #
  # @example
  #   distributor_vo = TvMaze::Distributor.new(raw_hash)
  #   distributor_record = TvShowService::UpsertDistributor.call(distributor_vo)
  #
  # @return [Distributor, nil] The persisted ActiveRecord Distributor or nil if none given.
  class UpsertDistributor
    # Upserts a distributor into the database using unique name constraint.
    #
    # @param distributor [TvMaze::Distributor, nil] The distributor value object.
    # @return [Distributor, nil] The persisted Distributor or nil if no input given.
    def self.call(distributor)
      return unless distributor

      Distributor.upsert(
        {
          name: distributor.name,
          country: distributor.country,
          kind: distributor.kind
        },
        unique_by: %i[name country]
      )

      Distributor.find_by(name: distributor.name)
    end
  end
end
