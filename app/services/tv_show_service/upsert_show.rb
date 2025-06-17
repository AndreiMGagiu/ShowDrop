# frozen_string_literal: true

module TvShowService
  # UpsertShow is responsible for inserting or updating a TvShow record
  # based on external provider data (e.g., from the TVMaze API).
  class UpsertShow
    # Inserts or updates a TvShow based on its external data.
    #
    # @param show [TvMaze::Show] A value object containing show attributes from the provider.
    # @return [TvShow, nil] The persisted TvShow record, or nil if not found after upsert.
    def self.call(show)
      TvShow.upsert(
        {
          provider_identifier: show.id,
          name: show.name,
          language: show.language,
          status: show.status,
          rating: show.rating,
          summary: show.summary,
          image: show.image,
          premiered: show.premiered
        },
        unique_by: :provider_identifier
      )
    end
  end
end
