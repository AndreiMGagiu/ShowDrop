# frozen_string_literal: true

# TvMaze::Episode wraps a single episode hash from the TVMaze API response
# and exposes parsed, normalized values for use in application logic.
#
# This value object acts as the gateway to episode details such as name,
# airdate, and associated show metadata.
#
# Example:
#   episode = TvMaze::Episode.new(raw_hash)
#   episode.name       # => "Winter Is Coming"
#   episode.airdate    # => #<Date: 2025-08-15>
#   episode.show.name  # => "Game of Thrones"
module TvMaze
  class Episode
    # @param data [Hash] The raw episode hash from the TVMaze API.
    def initialize(data)
      @data = data
    end

    # @return [Hash] The original raw hash passed from the API.
    attr_reader :data

    # @return [Integer] The episode's unique identifier.
    def id
      data['id']
    end

    # @return [String] The name of the episode.
    def name
      data['name']
    end

    # @return [Date, nil] The parsed airdate of the episode.
    def airdate
      Date.parse(data['airdate']) if data['airdate'].present?
    rescue ArgumentError
      nil
    end

    # @return [Time, nil] The parsed UTC timestamp for when the episode airs.
    def airstamp
      Time.zone.parse(data['airstamp']) if data['airstamp'].present?
    rescue ArgumentError
      nil
    end

    # @return [Integer, nil] The runtime of the episode in minutes.
    def runtime
      data['runtime']
    end

    # @return [Integer, nil] The season number the episode belongs to.
    def season
      data['season']
    end

    # @return [Integer, nil] The episode number within the season.
    def number
      data['number']
    end

    # @return [TvMaze::Show, nil] A wrapped show object if available.
    def show
      @show ||= TvMaze::Show.new(data['show']) if data['show']
    end
  end
end
