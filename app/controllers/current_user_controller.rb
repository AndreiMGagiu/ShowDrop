# frozen_string_literal: true

# Controller to fetch details of the currently authenticated user.
#
# This is typically used by frontend clients after authentication to retrieve
# user information without requiring additional input (e.g., tokens or params).
#
# Requires the user to be authenticated via Devise + JWT.
#
# @example GET /current_user
#   {
#     "email": "user@example.com",
#     "name": "John Doe",
#     ...
#   }
#
class CurrentUserController < ApplicationController
  before_action :authenticate_user!

  # Returns the current authenticated user's serialized data.
  #
  # @return [JSON] serialized user attributes
  def index
    render json: UserSerializer.new(current_user).serializable_hash[:data][:attributes], status: :ok
  end
end
