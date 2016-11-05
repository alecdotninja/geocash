class Transfer < ApplicationRecord
  belongs_to :account, inverse_of: :transfers

  validates :account, :authorization_code, :amount, presence: true

  scope :confirmed, -> { where.not(confirmed_at: nil) }
  scope :unconfirmed, -> { where(confirmed_at: nil) }
  scope :withdrawals, -> { where(arel_table[:amount].lt(0)) }
  scope :deposits, -> { where(arel_table[:amount].gt(0)) }
end
