class EnableUuidOssp < ActiveRecord::Migration[5.0]
  def up
    execute <<-SQL
      CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
    SQL
  end

  def down
  end
end