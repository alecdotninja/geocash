class CreateTransfers < ActiveRecord::Migration[5.0]
  def change
    create_table :transfers, id: :uuid do |t|
      t.timestamps null: false
      t.references :account, type: :uuid, foreign_key: true
      t.decimal :amount
      t.string :authorization_code, null: false
      t.string :confirmation_code
      t.datetime :confirmed_at

    end
  end
end
