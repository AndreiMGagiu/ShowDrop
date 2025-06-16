# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::TvShowsController', type: :request do
  include_context 'authenticated user'

  let(:unauth_error) do
    {
      'code' => 401,
      'message' => 'You need to sign in or sign up before continuing.',
      'status' => 'unauthorized'
    }
  end

  describe 'GET /api/v1/tv_shows' do
    before do
      create(:tv_show, name: 'Breaking Bad', premiered: '2008-01-20')
      create(:tv_show, name: 'Game of Thrones', premiered: '2011-04-17')
    end

    context 'when user is authenticated' do
      before { get '/api/v1/tv_shows', headers: auth_headers }

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

    context 'when user is unauthenticated' do
      before { get '/api/v1/tv_shows' }

      it 'returns 401 Unauthorized' do
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns the correct error message structure' do
        expect(response.parsed_body['error']).to eq(unauth_error)
      end
    end
  end

  describe 'GET /api/v1/tv_shows with filters' do
    before do
      create(:tv_show, name: 'Sherlock', language: 'English')
      create(:tv_show, name: 'La Casa de Papel', language: 'Spanish')
    end

    context 'when user is authenticated' do
      before { get '/api/v1/tv_shows', params: { language: 'Spanish' }, headers: auth_headers }

      it 'filters and returns only Spanish shows' do
        languages = response.parsed_body['data'].map { |d| d.dig('data', 'attributes', 'language') }.uniq
        expect(languages).to eq(['Spanish'])
      end
    end

    context 'when user is unauthenticated' do
      before { get '/api/v1/tv_shows', params: { language: 'Spanish' } }

      it 'returns 401 Unauthorized' do
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns the correct error message structure' do
        expect(response.parsed_body['error']).to eq(unauth_error)
      end
    end
  end

  describe 'GET /api/v1/tv_shows/:id' do
    let!(:tv_show) { create(:tv_show, name: 'Stranger Things') }

    context 'when user is authenticated' do
      it 'returns 200 OK for existing record' do
        get "/api/v1/tv_shows/#{tv_show.id}", headers: auth_headers
        expect(response).to have_http_status(:ok)
      end

      it 'returns the correct TV show name' do
        get "/api/v1/tv_shows/#{tv_show.id}", headers: auth_headers
        expect(response.parsed_body['data']['attributes']['name']).to eq('Stranger Things')
      end

      it 'returns 404 Not Found for non-existent record' do
        get '/api/v1/tv_shows/non-existent-id', headers: auth_headers
        expect(response).to have_http_status(:not_found)
      end

      it 'returns not found error for non-existent record' do
        get '/api/v1/tv_shows/non-existent-id', headers: auth_headers
        expect(response.parsed_body['error']['code']).to eq(404)
      end
    end

    context 'when user is unauthenticated' do
      it 'returns 401 Unauthorized for existing record' do
        get "/api/v1/tv_shows/#{tv_show.id}"
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns error structure for existing record' do
        get "/api/v1/tv_shows/#{tv_show.id}"
        expect(response.parsed_body['error']).to eq(unauth_error)
      end

      it 'returns 401 Unauthorized for non-existent record' do
        get '/api/v1/tv_shows/non-existent-id'
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns error structure for non-existent record' do
        get '/api/v1/tv_shows/non-existent-id'
        expect(response.parsed_body['error']).to eq(unauth_error)
      end
    end
  end
end
