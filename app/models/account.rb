class Account < ApplicationRecord
  has_many :transfers, dependent: :restrict_with_error, inverse_of: :account

end
