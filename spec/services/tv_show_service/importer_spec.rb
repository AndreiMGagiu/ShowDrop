# spec/services/tv_show_service/importer_spec.rb
require 'rails_helper'

RSpec.describe TvShowService::Importer do
  let(:date) { Date.current }
  let(:date_str) { date.strftime('%Y-%m-%d') }
  let(:api_url) { "https://api.tvmaze.com/schedule?date=#{date_str}" }

  let(:episode_payload) do
    [
      {
        'id' => 123,
        'name' => 'Test Episode',
        'airdate' => date_str,
        'airstamp' => date.to_time.change(hour: 20).iso8601,
        'runtime' => 60,
        'season' => 2,
        'number' => 3,
        'show' => {
          'id' => 999,
          'name' => 'Test Show',
          'language' => 'English',
          'status' => 'Running',
          'rating' => { 'average' => 8.4 },
          'summary' => 'A very good show.',
          'image' => { 'medium' => 'http://example.com/show.jpg' },
          'network' => {
            'name' => 'Test Network',
            'country' => { 'name' => 'USA' },
            'type' => 'network'
          }
        }
      }
    ]
  end

  before do
    stub_request(:get, api_url)
      .to_return(
        status: 200,
        body: episode_payload.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  it 'creates TvShow, Distributor, and Release from fetched episodes' do
    expect do
      described_class.new(days: 1).call
    end.to change(TvShow, :count).by(1)
                                 .and change(Distributor, :count).by(1)
                                                                 .and change(Release, :count).by(1)
  end
end
