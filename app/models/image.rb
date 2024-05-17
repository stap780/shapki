class Image < ApplicationRecord
  belongs_to :variant

  include Rails.application.routes.url_helpers
  require "image_processing/vips"

  acts_as_list scope: [:variant_id, :position]

  has_one_attached :file, service: :timeweb do |attachable|
    # attachable.variant :sm, resize_to_limit: [120, 120]
    attachable.variant :thumb, resize_to_limit: [200, 200]
    attachable.variant :default, saver: {strip: true}
    # PNG is increase volume - only example
    # attachable.variant :def_png, saver: { strip: true, compression: 9 }, format: "png"
    # WEBP not use - only example
    # attachable.variant :def_webp, saver: { strip: true, quality: 75, lossless: false, alpha_q: 85, reduction_effort: 6, smart_subsample: true }, format: "webp"
  end

  validate :is_image?

  before_validation :set_position_if_nil, on: :create

  scope :without_uid, -> {where(uid: [nil,''])}

  def self.ransackable_attributes(auth_object = nil)
    Image.attribute_names
  end

  def full_url
    host = Rails.env.development? ? "http://localhost:3000" : "https://app.%D1%88%D0%B0%D0%BF%D0%BB%D0%B0%D0%BD%D0%B4%D0%B8%D1%8F.%D1%80%D1%84"
    host+rails_blob_path(self.file, only_path: true) if self.file.attached?
  end

  def s3_url
    "https://s3.timeweb.cloud/#{self.file.service.bucket.name}/#{self.file.blob.key}"
  end

  private

  def is_image?
    return unless file.attached?

    unless file.blob.byte_size <= 10.megabyte
      errors.add(:file, "is too big")
    end

    acceptable_types = ["image/jpeg", "image/png"]
    unless acceptable_types.include?(file.content_type)
      errors.add(:file, "must be a JPEG or PNG")
    end
  end

  def set_position_if_nil
    return if position.present?
    last = Image.where(variant_id: variant.id).last
    self.position = last.present? ? last.position + 1 : 1
  end

end
