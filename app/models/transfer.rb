class Transfer < ApplicationRecord
  belongs_to :account, inverse_of: :transfers
  belongs_to :geocash, inverse_of: :transfers

  scope :confirmed, -> { where.not(confirmed_at: nil) }
  scope :unconfirmed, -> { where(confirmed_at: nil) }
  scope :withdrawals, -> { where(arel_table[:amount].lt(0)) }
  scope :deposits, -> { where(arel_table[:amount].gt(0)) }

  validates :account, :authorization_code, presence: true
  validates :amount, numericality: { only_integer: true, greater_than_or_equal_to: -100, less_than_or_equal_to: 100, not_equal_to: 0 }

  before_validation :assign_new_authorization_code, unless: :authorization_code?
  before_validation :apply_confirmation_code, if: :confirmation_code?, unless: :confirmed?

  attr_accessor :confirmation_code

  delegate :preshared_secret, to: :geocash, allow_nil: true

  def confirmed?
    confirmed_at?
  end

  def confirmation_code?
    confirmation_code.present?
  end

  def generate_confirmation_code
    CodeManager.generate(amount: amount, secret: confirmation_code_secret) if amount.present? && confirmation_code_secret.present?
  end

  def generate_authorization_code
    CodeManager.generate(amount: amount, secret: authorization_code_secret) if amount.present? && authorization_code_secret.present?
  end

  def deposit?
    amount > 0 if amount
  end

  def withdrawal?
    amount < 0 if amount
  end

  private

  def assign_new_authorization_code
    self.authorization_code = generate_authorization_code
  end

  def apply_confirmation_code
    verified_amount = CodeManager.verified_amount(code: confirmation_code, secret: confirmation_code_secret)

    if verified_amount.present?
      self.amount = verified_amount
      self.confirmed_at = Time.now
    else
      errors.add(:confirmation_code, :invalid)
    end
  end

  def authorization_code_secret
    "AUTH-#{preshared_secret}" if preshared_secret.present?
  end

  def confirmation_code_secret
    "CONF-FOR-#{authorization_code}-#{preshared_secret}" if authorization_code.present? && preshared_secret.present?
  end
end
