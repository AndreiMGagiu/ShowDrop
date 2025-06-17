# app/controllers/api_controller.rb
class ApplicationController < ActionController::API
  include Pagy::Backend

  before_action :authenticate_user!, unless: :devise_controller?

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from JWT::ExpiredSignature, with: :render_token_expired
  rescue_from JWT::DecodeError, with: :render_token_invalid

  private

  def authenticate_user!
    if user_signed_in?
      super
    else
      render_unauthorized('You need to sign in or sign up before continuing.')
    end
  end

  def render_unauthorized(message = 'Unauthorized')
    render json: {
      error: {
        code: 401,
        status: 'unauthorized',
        message: message
      }
    }, status: :unauthorized
  end

  def render_not_found(message = 'Resource not found')
    render json: {
      error: {
        code: 404,
        status: 'not_found',
        message: message
      }
    }, status: :not_found
  end

  def render_token_expired
    render_unauthorized('Your token has expired. Please log in again.')
  end

  def render_token_invalid
    render_unauthorized('Invalid token. Please log in.')
  end
end
