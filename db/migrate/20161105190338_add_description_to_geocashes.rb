class AddDescriptionToGeocashes < ActiveRecord::Migration[5.0]
  def change
    add_column :geocashes, :description, :string

    Geocash.all.each_with_index do |geocash, i|
      geocash.description = i.to_s
      geocash.save!
    end

    change_column :geocashes, :description, :string, null: false
  end
end
