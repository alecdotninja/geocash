class Account < ApplicationRecord
  has_many :transfers, dependent: :destroy, inverse_of: :account

end
