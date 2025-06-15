# frozen_string_literal: true

# Serializes a TV show along with its distributors and episodes.
#
# Example usage:
#   TvShowsSerializer.new(tv_show).as_json
#   TvShowsSerializer.collection(tv_shows)
#
class TvShowsSerializer
  # @param tv_show [TvShow] The TV show instance to serialize.
  def initialize(tv_show)
    @tv_show = tv_show
  end

  # Builds the JSON:API-compliant hash structure for the TV show.
  #
  # @return [Hash] The serialized representation of the TV show.
  def as_json
    {
      data: {
        type: 'tv_show',
        id: tv_show.id,
        attributes: tv_show_attributes,
        relationships: {
          distributors: distributors_json,
          episodes: episodes_json
        }
      }
    }
  end

  # Serializes a collection of TV shows.
  #
  # @param tv_shows [Enumerable<TvShow>] A list of TvShow records.
  # @return [Array<Hash>] An array of serialized TV shows.
  def self.collection(tv_shows)
    tv_shows.map { |show| new(show).as_json }
  end

  private

  attr_reader :tv_show

  # @return [Hash] The core attributes of the TV show.
  def tv_show_attributes
    {
      name: tv_show.name,
      language: tv_show.language,
      premiered: tv_show.premiered,
      status: tv_show.status,
      rating: tv_show.rating,
      summary: tv_show.summary,
      image: tv_show.image
    }
  end

  # @return [Array<Hash>] An array of serialized distributors.
  def distributors_json
    tv_show.distributors.uniq.map do |distributor|
      {
        id: distributor.id,
        name: distributor.name,
        country: distributor.country,
        kind: distributor.kind
      }
    end
  end

  # @return [Array<Hash>] An array of serialized episode releases.
  def episodes_json
    tv_show.releases.map do |release|
      {
        id: release.id,
        episode_id: release.episode_id,
        episode_name: release.episode_name,
        airdate: release.airdate,
        airstamp: release.airstamp,
        runtime: release.runtime,
        season: release.season,
        number: release.number
      }
    end
  end
end
