json.extract! short_url, :id, :hash_integer, :long_url, :created_at, :updated_at
json.url short_url_url(short_url, format: :json)
