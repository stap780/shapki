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

  scope :with_not_sync_images, -> {joins(:images).merge(Image.without_uid).distinct}
  scope :without_images, -> {where.missing(:images)}
  scope :with_images, -> {where.associated(:images)}

  STATUS = ["New","Process","Finish","Error"]

  def self.ransackable_attributes(auth_object = nil)
    Variant.attribute_names
  end

  def self.ransackable_associations(auth_object = nil)
    ["images", "product"]
  end

  def self.ransackable_scopes(auth_object = nil)  # Variant.ransack({with_images: true}).result.count
    [:with_images, :without_images]
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

  def have_not_sync_images
    return true if self.images.present? && !!self.images.pluck(:uid) # array with empty values => true 
    false
  end

  private


end
