# frozen_string_literal: true

module ExceptionHandler
  class AuthenticationError < StandardError; end
  class InvalidToken < AuthenticationError; end
  class ExpiredToken < AuthenticationError; end
  class MissingToken < AuthenticationError; end
  class Unauthorized < AuthenticationError; end
end
