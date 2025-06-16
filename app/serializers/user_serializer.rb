# frozen_string_literal: true

# UserSerializer serializes user data into a JSON:API-compliant format.
class UserSerializer
  include JSONAPI::Serializer

  # @return [Integer] the unique ID of the user
  # @return [String] the user's email address
  # @return [DateTime] the datetime when the user was created
  attributes :id, :email, :created_at

  # @return [String, nil] the creation date in MM/DD/YYYY format
  attribute :created_date do |user|
    user.created_at&.strftime('%m/%d/%Y')
  end
end
