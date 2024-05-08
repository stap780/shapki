class Variant < ApplicationRecord
  belongs_to :product
  has_many :images, -> { order(position: :asc) }, dependent: :destroy
  accepts_nested_attributes_for :images, allow_destroy: true
  validates :uid, presence: true
  validates :uid, uniqueness: true
  include ActionView::RecordIdentifier
  include Rails.application.routes.url_helpers

  after_create_commit do 
    broadcast_append_to [product, :variants], target: dom_id(product, :variants), partial: "variants/variant", locals: { variant: self, product: product  }
    broadcast_update_to [product, :variants], target: dom_id(product, dom_id(Variant.new)), html: ''
  end

  after_update_commit do
      broadcast_replace_to [product, :variants], target: dom_id(product, dom_id(self)), partial: "variants/variant", locals: { variant: self, product: product }
  end

  after_destroy_commit do
    broadcast_remove_to [product, :variants], target: dom_id(product, dom_id(self))
  end

  STATUS = ["New","Process","Finish","Error"]

  def self.ransackable_attributes(auth_object = nil)
    Variant.attribute_names
  end

  def self.load_variants(product_id)
    ApiLoadVariantsJob.perform_now(product_id)
  end
  
  def api_import_images
    puts "api_import_images"
    ApiImportVariantImages.call(product.id, self.id)
  end

  def images_urls
    images.map do |image|
      image.full_url
    end
  end

  def s3_images_urls
    images.map do |image|
      image.s3_url
    end
  end

  private


end
