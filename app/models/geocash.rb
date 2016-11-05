class Geocash < ApplicationRecord
  PRESHARED_SECRET_BYTE_LENGTH = 128

  before_validation :generate_preshared_secret, unless: :preshared_secret?

  validates :preshared_secret, presence: true

  def preshared_secret
    self[:preshared_secret] ||= generate_preshared_secret
  end

  private

  def generate_preshared_secret
    self.preshared_secret = SecureRandom.random_bytes(PRESHARED_SECRET_BYTE_LENGTH)
  end
end
