# frozen_string_literal: true

module Users
  # Custom Devise controller for user sessions in API-only applications.
  #
  # This controller overrides the default Devise behavior to return structured
  # JSON responses instead of redirects, making it ideal for API clients such as
  # mobile apps or SPAs.
  #
  # It includes the `RackSessionFix` workaround to prevent session-related errors
  # in API-only Rails setups where session middleware is typically not used.
  #
  # @see RackSessionFix
  class SessionsController < Devise::SessionsController
    include RackSessionFix
    respond_to :json

    private

    # Overrides the default Devise response when a user successfully logs in.
    #
    # @param resource [User] the authenticated user resource
    # @param _opts [Hash] optional parameters (not used)
    #
    # @return [void]
    def respond_with(resource, _opts = {})
      render json: {
        status: { code: 200, message: 'Logged in successfully.' },
        data: UserSerializer.new(resource).serializable_hash[:data][:attributes]
      }, status: :ok
    end

    # Custom response for Devise logout (session destroy) requests.
    #
    # Returns a `200 OK` if a user is signed in and logs out,
    # or a `401 Unauthorized` if no active session is found.
    #
    # @return [void]
    def respond_to_on_destroy
      if current_user
        render json: {
          status: 200,
          message: 'Logged out successfully.'
        }, status: :ok
      else
        render json: {
          status: 401,
          message: "Couldn't find an active session."
        }, status: :unauthorized
      end
    end
  end
end
