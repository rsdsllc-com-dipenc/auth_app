class ApiKey < ApplicationRecord
  belongs_to :bearer, polymorphic: true
  before_create :generate_raw_token
  before_create :generate_token_digest

  HMAC_SECRET_KEY = Rails.application.credentials.api_key_hmac_secret_key

  # Attribute for storing and accessing the raw (non-hashed)
  # token value directly after creation
  # Value only available right after create
  # Raw token needs to be sent to the User/Bearer immediately after 
  # this ApiKey record is created otherwise it will be be lost
  attr_accessor :raw_token

  # Find the token
  def self.find_by_token!(token)
    find_by!(token_digest: generate_digest(token))
  end

  def self.find_by_token(token)
    find_by(token_digest: generate_digest(token))
  end

  # Generate the digest from the token. E.g. 686bcc07f00630c77485393e27c107a62827455b60e95964cd7102e7a8668548
  # One way hash
  # for the same token, hash will always be the same
  # ALWAYS TRUE: generate_digest("hello") == generate_digest("hello")
  def self.generate_digest(token)
    OpenSSL::HMAC.hexdigest("SHA256", HMAC_SECRET_KEY, token)
  end

  private

  # Generates a raw token. E.g. qvcnUbicmgiTgiibi3K4p8zbWwXNPz
  # This is what will be emailed to the user (bearer)
  def generate_raw_token
    self.raw_token = SecureRandom.base58(30)
  end

  # set the token_digest attribute to the digest of the token
  def generate_token_digest
    self.token_digest = self.class.generate_digest(raw_token)
  end
end
