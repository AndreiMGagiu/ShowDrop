# spec/services/tv_maze_client_spec.rb
require 'rails_helper'

RSpec.describe TvMazeClient do
  subject(:client) { described_class.new }

  let(:date) { Date.new(2025, 8, 15) }
  let(:formatted_date) { date.strftime('%Y-%m-%d') }
  let(:url) { "https://api.tvmaze.com/schedule?date=#{formatted_date}" }

  let(:fake_episodes) do
    [
      {
        'id' => 1,
        'name' => 'Pilot',
        'airdate' => formatted_date
      }
    ]
  end

  context 'when the request is successful' do
    before do
      stub_request(:get, "https://api.tvmaze.com/schedule")
        .with(query: { date: formatted_date })
        .to_return(status: 200, body: fake_episodes.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns an array of episodes' do
      expect(client.fetch_episodes(date)).to eq(fake_episodes)
    end
  end

  context 'when the response status is not 200' do
    before do
      stub_request(:get, url).to_return(status: 500, body: '')
    end

    it 'returns an empty array' do
      expect(client.fetch_episodes(date)).to eq([])
    end
  end

  context 'when a network error occurs' do
    before do
      stub_request(:get, url).to_raise(SocketError.new('Network down'))
      allow(Rails.logger).to receive(:error)
    end

    it 'logs the error' do
      client.fetch_episodes(date)
      expect(Rails.logger).to have_received(:error).with(
        hash_including(message: 'TVMaze API Error', error: 'Network down', date: date)
      )
    end

    it 'returns an empty array' do
      expect(client.fetch_episodes(date)).to eq([])
    end
  end
end
