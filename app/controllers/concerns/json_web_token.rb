# Module: JsonWebToken
#
# Provides utility methods for encoding and decoding JSON Web Tokens (JWT) using a secret key.
#
# Constants:
# - SECRET_KEY: The secret key used to encode and decode JWTs, fetched from Rails credentials or environment variable.
#
# Methods:
#
# - jwt_encode(payload, exp = 24.hours.from_now)
#     Encodes a given payload into a JWT token with an expiration time.
#     @param payload [Hash] The payload to encode into the JWT.
#     @param exp [Time] The expiration time for the token (default: 24 hours from now).
#     @return [String] The encoded JWT token.
#
# - jwt_decode(token)
#     Decodes a JWT token and returns the payload as a HashWithIndifferentAccess.
#     @param token [String] The JWT token to decode.
#     @return [HashWithIndifferentAccess, nil] The decoded payload, or nil if decoding fails or the token is expired.
module JsonWebToken
  module_function
  SECRET_KEY = Rails.application.credentials.secret_key_base || ENV["SECRET_KEY_BASE"]

  def jwt_encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  def jwt_decode(token)
    decoded = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new decoded
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end
end
