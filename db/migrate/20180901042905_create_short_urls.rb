class CreateShortUrls < ActiveRecord::Migration[5.2]
  def change
    create_table :short_urls do |t|
      t.integer :hash_integer, limit: 8, index: true, unique: true
      t.string :long_url
      t.timestamps
    end
  end
end
