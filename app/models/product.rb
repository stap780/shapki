class Product < ApplicationRecord
    require "open-uri"
    include ActionView::RecordIdentifier
    has_many :variants, dependent: :destroy
    accepts_nested_attributes_for :variants, allow_destroy: true
    
    before_save :normalize_data_white_space
    before_create ->(product) { product.status = "New" if product.status.blank? }

    after_create_commit { broadcast_prepend_to "products" }
    after_update_commit { broadcast_replace_to "products" }
    after_update_commit { broadcast_replace_to "product_#{self.id}_show", target: dom_id(self,:show), partial: 'products/inline_form', locals: {product: self} }

    validates :title, presence: true
    validates :uid, presence: true
    validates :uid, uniqueness: true

    scope :have_variants_whithout_images, -> {joins(:variants).merge(Variant.without_images).distinct}
    scope :have_variants_with_not_sync_images, -> {joins(:variants).merge(Variant.with_not_sync_images).distinct}


    XML_URL = "https://xn--80aamqmnl4e8c.xn--p1ai/marketplace/4234280.xml"
    STATUS = ["New","Process","Finish","Error"]

    def self.ransackable_attributes(auth_object = nil)
        Product.attribute_names
    end

    def self.ransackable_associations(auth_object = nil)
      ["variants"]
    end
    
    def self.ransackable_scopes(auth_object = nil)  # Product.ransack({have_variants_whithout_images: true}).result.count
      [:have_variants_whithout_images, :have_variants_with_not_sync_images]
    end

    def self.load_xml_data
        file = "#{Rails.public_path}"+"/shapki.xml"
        File.delete(file) if File.file?(file)
        download = URI.open(Product::XML_URL)
        IO.copy_stream(download, file)
        sleep(0.5)
        doc = Nokogiri::XML(open(file))
        offers = doc.xpath("//offer")
        puts offers.count
        offers.each do |item|
            uid = item["id"]
            title = item.xpath('model').text
            Product.where(uid: uid).first_or_create!(uid: uid, title: title)
        end
    end

    def self.insales_api_create_xml
        begin
          col_ids = InsalesApi::Collection.find( :all).map{|p| p.id}
          property_id = InsalesApi::Property.first.id
          data = {
                "marketplace": {
                  "name": "YM myappda #{Time.now}",
                  "type": "Marketplace::ModelYandexMarket",
                  "shop_name": "YM myappda",
                  "shop_company": "YM myappda",
                  "description_type": 1,
                  "vendor_id": property_id,
                  "adult": 0,
                  "page_encoding": "utf-8",
                  "image_style": "thumb",
                  "model_type": "name",
                  "collection_ids": col_ids,
                  "use_variants": true
                }
              }
          new_market = InsalesApi::Marketplace.new(data)
          new_market.save
          rescue StandardError => e
            puts "StandardError => "+e.to_s
            puts "e.response => "+e.response.to_s if e.response
            puts "e.response.body => "+e.response.body.to_s if e.response && e.response.body
          rescue ActiveResource::ResourceNotFound
            puts  'not_found 404'
          rescue ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid
            puts "ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid"
          rescue ActiveResource::UnauthorizedAccess
            puts "Failed.  Response code = 401. Response message = Unauthorized"
          rescue ActiveResource::ClientError
            puts "ActiveResource::ClientError - Failed. Response code = 423.  Response message = Locked. Это наверно тарифный план клиента"
        else
            puts new_market.id
          new_market
        end

        # market = InsalesApi::Marketplace.find(4234280)
        # market.url
    end

    def variants_images_size
      return '' unless self.variants
      self.variants.includes(:images).map(&:images).flatten.size
    end

    private

    def normalize_data_white_space
        attributes.each do |key, value|
          self[key] = value.squish if value.respond_to?(:squish)
        end
    end


end
