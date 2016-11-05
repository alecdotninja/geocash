class Geocash < ApplicationRecord
  PRESHARED_SECRET_BYTE_LENGTH = 128

  has_many :transfers, dependent: :restrict_with_error, inverse_of: :geocashes

  before_validation :assign_new_preshared_secret, unless: :preshared_secret?

  validates :preshared_secret, presence: true

  def generate_preshared_secret
    SecureRandom.random_bytes(PRESHARED_SECRET_BYTE_LENGTH)
  end

  def preshared_secret_base64
    @preshared_secret_base64 ||= Base64.encode64(preshared_secret) if preshared_secret.present?
  end

  private

  def assign_new_preshared_secret
    self.preshared_secret = generate_preshared_secret
  end
end
