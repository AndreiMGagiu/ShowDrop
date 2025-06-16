# frozen_string_literal: true

module Users
  # Custom Devise controller for user registration in API-only applications.
  #
  # This controller overrides the default Devise behavior to return structured
  # JSON responses instead of HTML redirects, making it suitable for frontend clients
  # like mobile apps or single-page applications.
  #
  # It also includes a workaround (`RackSessionFix`) to prevent Devise from raising
  # session-related errors in API-only mode.
  #
  # @see RackSessionFix
  class RegistrationsController < Devise::RegistrationsController
    include RackSessionFix
    respond_to :json

    private

    # Customizes the response format for registration-related actions.
    #
    # @param resource [User] the user resource being registered or deleted
    # @param _opts [Hash] additional options (unused)
    #
    # @return [void]
    def respond_with(resource, _opts = {})
      if request.method == "POST" && resource.persisted?
        render_signup_success(resource)
      elsif request.method == "DELETE"
        render_account_deletion_success
      else
        render_signup_failure(resource)
      end
    end

    # Renders a JSON response for a successful signup.
    #
    # @param resource [User]
    # @return [void]
    def render_signup_success(resource)
      render json: {
        status: { code: 200, message: "Signed up successfully." },
        data: UserSerializer.new(resource).serializable_hash[:data][:attributes]
      }, status: :ok
    end

    # Renders a JSON response for successful account deletion.
    #
    # @return [void]
    def render_account_deletion_success
      render json: {
        status: { code: 200, message: "Account deleted successfully." }
      }, status: :ok
    end

    # Renders a JSON response for failed signup attempt.
    #
    # @param resource [User]
    # @return [void]
    def render_signup_failure(resource)
      render json: {
        status: {
          code: 422,
          message: "User couldn't be created successfully. #{resource.errors.full_messages.to_sentence}"
        }
      }, status: :unprocessable_entity
    end
  end
end
