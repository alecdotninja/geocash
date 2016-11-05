class Account < ApplicationRecord
  has_many :transfers, dependent: :restrict_with_error, inverse_of: :account

  def balance
    transfers.deposits.sum(:amount) + transfers.withdrawals.sum(:amount)
  end

  def available_balance
    transfers.deposits.confirmed.sum(:amount) + transfers.withdrawals.sum(:amount)
  end

  def confirmed_balance
    transfers.confirmed.sum(:amount)
  end

  def unconfirmed_withdrawal_amount
    transfers.unconfirmed.withdrawals.sum(:amount)
  end

  def unconfirmed_deposit_amount
    transfers.unconfirmed.deposits.sum(:amount)
  end
end