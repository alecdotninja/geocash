class Account < ApplicationRecord
  has_many :transfers, dependent: :destroy, inverse_of: :account

  def confirmed_balance
    transfers.confirmed.sum(:amount)
  end

  def unconfirmed_withdrawal_amount
    transfers.unconfirmed.withdrawals.sum(:amount)
  end

  def unconfirmed_deposit_amount
    transfers.unconfirmed.deposits.sum(:amount)
  end

  def available_balance
    confirmed_balance - unconfirmed_withdrawal_amount
  end
end