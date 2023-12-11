class ApiKey < ApplicationRecord
  HMAC_SECRET_KEY = Rails.application.credentials.api_key_hmac_secret_key
  TOKEN_NAMESPACE = "tkn"

  # Encrypt random token prefix using Active Record Encryption
  encrypts :random_token_prefix, deterministic: true

  belongs_to :bearer, polymorphic: true
  before_validation :set_common_token_prefix, on: :create
  before_validation :generate_random_token_prefix, on: :create
  before_create :generate_raw_token
  before_create :generate_token_digest

  # rows that have the same bearer_id and bearer_type cannot have the same random_token_prefix
  validates :random_token_prefix, uniqueness: { scope: [:bearer_id, :bearer_type] }

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

  # "usr" or "org". Does not save in column.
  def common_token_subprefix
    if bearer_type == "User"
      "usr"
    elsif bearer_type == "Organization"
      "org"
    end
  end

  # Eg: "tkn_usr_". Saves in column common_token_prefix
  def set_common_token_prefix
    self.common_token_prefix = "#{TOKEN_NAMESPACE}_#{common_token_subprefix}_"
  end

  # Eg: "1zZe1R". Saves in column random_token_prefix
  def generate_random_token_prefix
    self.random_token_prefix = SecureRandom.base58(6)
  end

  # Generates a raw token. E.g. tkn_usr_1zZe1RWcijSdkKaSdEav7EVakJEj2V
  # This is what will be emailed to the user (bearer)
  def generate_raw_token
    self.raw_token = [common_token_prefix, random_token_prefix, SecureRandom.base58(24)].join("")
  end

  # set the token_digest attribute to the digest of the raw_token
  def generate_token_digest
    self.token_digest = self.class.generate_digest(raw_token)
  end
end
