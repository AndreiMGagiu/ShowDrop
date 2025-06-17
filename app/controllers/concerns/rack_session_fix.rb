# frozen_string_literal: true

# RackSessionFix is a workaround for Devise in API-only Rails applications.
#
# In a typical Rails application with session-based authentication, Devise relies
# on `rack.session` middleware to manage sessions. However, in API-only apps,
# session middleware is disabled by default (e.g., `config.api_only = true`),
# which causes Devise to raise errors in certain controller actions that expect
# a session to exist (e.g., sign_in, sign_out, or failed authentications).
#
# This module injects a "fake" session object into the request environment,
# ensuring Devise doesn't raise exceptions due to a missing `rack.session`.
#
# Why it’s safe:
#   The FakeRackSession behaves like a no-op session store — it implements
#   `enabled?` returning false, and inherits from `Hash`, satisfying Devise’s
#   expectation without persisting anything.
#
# Reference:
#   https://github.com/heartcombo/devise/issues/4752
#
module RackSessionFix
  extend ActiveSupport::Concern

  # A minimal no-op session store that mimics the session interface
  # Devise expects while disabling actual session behavior.
  class FakeRackSession < Hash
    def enabled?
      false
    end
  end

  included do
    before_action :set_fake_rack_session_for_devise

    private

    def set_fake_rack_session_for_devise
      request.env['rack.session'] ||= FakeRackSession.new
    end
  end
end
