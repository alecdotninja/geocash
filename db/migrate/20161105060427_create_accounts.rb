class CreateAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :accounts, id: :uuid do |t|
      t.timestamps  null: false
    end
  end
end
