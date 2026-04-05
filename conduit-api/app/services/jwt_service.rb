# frozen_string_literal: true

class JwtService
  ALGORITHM = 'HS256'
  EXPIRATION = 24.hours

  def self.encode(payload)
    payload = payload.merge(exp: EXPIRATION.from_now.to_i)
    JWT.encode(payload, secret, ALGORITHM)
  end

  def self.decode(token)
    decoded = JWT.decode(token, secret, true, { algorithm: ALGORITHM })
    HashWithIndifferentAccess.new(decoded.first)

  rescue JWT::ExpiredSignature
    raise ExceptionHandler::ExpiredToken

  rescue JWT::DecodeError
    raise ExceptionHandler::InvalidToken
  end

  private
  def self.secret
    Rails.application.credentials.jwt[:secret]
  end
end
