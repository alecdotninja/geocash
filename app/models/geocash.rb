class Geocash < ApplicationRecord
  PRESHARED_SECRET_BYTE_LENGTH = 128

  has_many :transfers, dependent: :restrict_with_error, inverse_of: :geocash

  before_validation :assign_new_preshared_secret, unless: :preshared_secret?

  validates :preshared_secret, presence: true

  def generate_preshared_secret
    (0...8).map { SecureRandom.random_number(36**16).to_s(36).rjust(16, '0') }.join ''
  end

  private

  def assign_new_preshared_secret
    self.preshared_secret = generate_preshared_secret
  end
end
