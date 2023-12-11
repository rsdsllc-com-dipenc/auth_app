class User < ApplicationRecord
  has_many :api_keys, as: :bearer, dependent: :destroy
  validates :email, presence: true, uniqueness: true, format: { with: /\A[^@\s]+@[^@\s]+\z/ }
  validates :name, presence: true, length: { maximum: 255 }
end
