class Transfer < ApplicationRecord
  belongs_to :account, inverse_of: :transfers

  validates :account, presence: true
end
