class CreateGeocashes < ActiveRecord::Migration[5.0]
  def change
    create_table :geocashes, id: :uuid do |t|
      t.timestamps null: false

      t.binary :preshared_secret, null: false
    end
  end
end
