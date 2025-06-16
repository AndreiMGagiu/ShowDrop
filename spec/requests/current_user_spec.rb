# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "CurrentUserController", type: :request do
  include_context 'authenticated user'

  describe "GET /current_user" do
    context 'when authenticated' do
      before { get "/current_user", headers: auth_headers }

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      it "returns the user's email" do
        expect(response.parsed_body['email']).to eq(user.email)
      end

      it "includes the user ID" do
        expect(response.parsed_body).to include('id')
      end

      it "includes created_at timestamp" do
        expect(response.parsed_body).to include('created_at')
      end

      it "includes formatted created_date" do
        expect(response.parsed_body).to include('created_date')
      end
    end

    context 'when unauthenticated' do
      before { get "/current_user" }

      it 'returns 401 Unauthorized' do
        expect(response).to have_http_status(:unauthorized)
      end

      it 'includes an error message' do
        expect(response.parsed_body['error']['message']).to eq('You need to sign in or sign up before continuing.')
      end

      it 'includes an error code' do
        expect(response.parsed_body['error']['code']).to eq(401)
      end

      it 'includes an error status' do
        expect(response.parsed_body['error']['status']).to eq('unauthorized')
      end
    end
  end
end
