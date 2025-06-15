module TvShowService
  class UpsertShow
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

      TvShow.find_by(provider_identifier: show.id)
    end
  end
end
