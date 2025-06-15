# frozen_string_literal: true

# TvMaze::Show wraps a show hash from the TVMaze API response
# and exposes normalized accessors for key attributes such as name, status,
# language, rating, and associated distributor (network or web channel).
#
# This value object is used by `TvMaze::Episode` to expose its associated show.
#
# Example:
#   show = TvMaze::Show.new(raw_hash)
#   show.name        # => "Game of Thrones"
#   show.language    # => "English"
#   show.distributor # => <TvMaze::Distributor>
module TvMaze
  class Show
    # @param data [Hash] The raw show hash from the TVMaze API.
    def initialize(data)
      @data = data
    end

    # @return [Hash] The original raw show hash.
    attr_reader :data

    def premiered
      Date.parse(data['premiered'])
    end

    # @return [Integer] The unique ID of the show.
    def id
      data['id']
    end

    # @return [String] The name/title of the show.
    def name
      data['name']
    end

    # @return [String, nil] The language of the show (e.g., "English").
    def language
      data['language']
    end

    # @return [String, nil] The current status of the show (e.g., "Running").
    def status
      data['status']
    end

    # @return [Float, nil] The average viewer rating.
    def rating
      data.dig('rating', 'average')
    end

    # @return [String, nil] A short summary of the show.
    def summary
      data['summary']
    end

    # @return [String, nil] The URL to the show's image (medium resolution).
    def image
      data.dig('image', 'medium')
    end

    # @return [TvMaze::Distributor, nil] The wrapped distributor (network or webChannel), if present.
    def distributor
      distributor_data = data['network'] || data['webChannel']
      TvMaze::Distributor.new(distributor_data) if distributor_data
    end
  end
end
