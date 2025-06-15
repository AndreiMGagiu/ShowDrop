# frozen_string_literal: true

# TvMaze::Distributor wraps a distributor hash (TV network or web channel)
# from the TVMaze API response and provides convenient accessors.
#
# This value object is used to encapsulate distributor data
# such as name, country, and kind (e.g. 'network' or 'web_channel').
#
# Example:
#   distributor = TvMaze::Distributor.new(raw_hash)
#   distributor.name     # => "HBO"
#   distributor.country  # => "USA"
#   distributor.kind     # => "network"
module TvMaze
  class Distributor
    # @param data [Hash] The raw distributor hash from the TVMaze API response.
    def initialize(data)
      @data = data
    end

    # @return [Hash] The original raw hash passed from the API.
    attr_reader :data

    # @return [String, nil] The name of the distributor (e.g. "HBO").
    def name
      data['name']
    end

    # @return [String, nil] The country name (e.g. "USA") if available.
    def country
      data.dig('country', 'name')
    end

    # @return [String] The kind of distributor, defaults to 'network'.
    def kind
      data['type'] || 'network'
    end
  end
end
