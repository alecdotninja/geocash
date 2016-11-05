class CreateTransfers < ActiveRecord::Migration[5.0]
  def change
    create_table :transfers, id: :uuid do |t|
      t.timestamps null: false
      t.references :account, type: :uuid, foreign_key: true, null: false
      t.references :geocash, type: :uuid, foreign_key: true, null: false
      t.integer :amount, null: false
      t.string :authorization_code, null: false
      t.datetime :confirmed_at
    end
  end
end
