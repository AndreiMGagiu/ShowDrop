# frozen_string_literal: true

# TvMazeClient is responsible for retrieving scheduled TV show episodes
# from the TVMaze public API for a given date.
# API docs: https://www.tvmaze.com/api#schedule
class TvMazeClient
  # Fetches scheduled episodes for a specific date.
  #
  # @param date [Date] The date for which to fetch the episode schedule.
  # @return [Array<Hash>] An array of episode hashes. Returns an empty array
  #   if the API request fails or no episodes are found.
  #
  # @raise [SocketError, Net::OpenTimeout, HTTParty::Error]
  #   If a network-related error occurs (rescued internally and logged).
  def fetch_episodes(date)
    @responses ||= {}
    @responses[date] ||= begin
      res = response(date)
      res.code == 200 ? res.parsed_response : []
    end
  rescue SocketError, Net::OpenTimeout, HTTParty::Error => e
    Rails.logger.error(message: "TVMaze API Error", error: e.message, date: date)
    []
  end

  private

  # Makes a raw GET request to the TVMaze schedule API.
  #
  # @param date [Date] The date to query.
  # @return [HTTParty::Response] The raw response from the API.
  def response(date)
    HTTParty.get(
      "https://api.tvmaze.com/schedule",
      query: { date: date.strftime('%Y-%m-%d') }
    )
  end
end
