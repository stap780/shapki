class Import < ApplicationRecord

    has_one_attached :file, service: :timeweb
    validates :title, presence: true
    # validates :link, presence: true
    before_save :normalize_data_white_space

    include ActionView::RecordIdentifier
    include Rails.application.routes.url_helpers

    STATUS = ["New","Process","Finish","Error"]

    def self.ransackable_attributes(auth_object = nil)
        Import.attribute_names
    end
  
    after_create_commit { broadcast_append_to "imports" }
    after_update_commit { broadcast_replace_to "imports" }
    after_destroy_commit { broadcast_remove_to "imports" }
  

    def full_url
      host = Rails.env.development? ? "http://localhost:3000" : "https://app.%D1%88%D0%B0%D0%BF%D0%BB%D0%B0%D0%BD%D0%B4%D0%B8%D1%8F.%D1%80%D1%84"
      host+rails_blob_path(self.file, only_path: true) if self.file.attached?
    end
  
    def s3_url
      "https://s3.timeweb.cloud/#{self.file.service.bucket.name}/#{self.file.blob.key}"
    end

    private

    def normalize_data_white_space
      attributes.each do |key, value|
        self[key] = value.squish if value.respond_to?(:squish)
      end
    end

end
