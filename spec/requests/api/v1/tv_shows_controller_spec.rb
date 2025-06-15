# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::TvShowsController', type: :request do
  describe 'GET /api/v1/tv_shows' do
    before do
      create(:tv_show, name: 'Breaking Bad', premiered: '2008-01-20')
      create(:tv_show, name: 'Game of Thrones', premiered: '2011-04-17')
      get '/api/v1/tv_shows'
    end

    it 'returns a successful response' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns a list of TV shows' do
      expect(response.parsed_body['data'].size).to eq(2)
    end

    it 'includes pagination metadata' do
      expect(response.parsed_body['pagination'].keys).to include('page', 'items', 'pages', 'count')
    end
  end

  describe 'GET /api/v1/tv_shows with filters' do
    it 'filters by language' do
      create(:tv_show, name: 'Sherlock', language: 'English')
      create(:tv_show, name: 'La Casa de Papel', language: 'Spanish')

      get '/api/v1/tv_shows', params: { language: 'Spanish' }

      languages = response.parsed_body['data'].map { |d| d.dig('data', 'attributes', 'language') }.uniq
      expect(languages).to eq(['Spanish'])
    end
  end

  describe 'GET /api/v1/tv_shows/:id' do
    context 'when the record exists' do
      let(:tv_show) { create(:tv_show, name: 'Stranger Things') }

      before { get "/api/v1/tv_shows/#{tv_show.id}" }

      it 'returns a successful response' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns the correct TV show name' do
        expect(response.parsed_body['data']['attributes']['name']).to eq('Stranger Things')
      end
    end

    context 'when the record does not exist' do
      before { get '/api/v1/tv_shows/non-existent-id' }

      it 'returns a 404 status code' do
        expect(response).to have_http_status(:not_found)
      end

      it 'returns an error message' do
        expect(response.parsed_body['error']).to eq('TV show not found')
      end
    end
  end
end
