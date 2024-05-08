json.extract! product, :id, :status, :title, :uid, :created_at, :updated_at
json.url product_url(product, format: :json)
