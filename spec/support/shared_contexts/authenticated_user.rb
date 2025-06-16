# frozen_string_literal: true

RSpec.shared_context 'authenticated user' do
  let(:user) { create(:user, password: 'password123') }

  let(:auth_headers) do
    post '/login', params: {
      user: {
        email: user.email,
        password: 'password123'
      }
    }, as: :json

    token = response.headers['Authorization']
    { 'Authorization' => token }
  end
end
