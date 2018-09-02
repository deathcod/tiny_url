class UpdateLongUrlToBlob < ActiveRecord::Migration[5.2]
  def change
    change_column :short_urls, :long_url, :text
  end
end
