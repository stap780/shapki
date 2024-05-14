class Import < ApplicationRecord

    has_one_attached :file, service: :timeweb
    validates :title, presence: true
    validates :link, presence: true
    before_save :normalize_data_white_space

    include ActionView::RecordIdentifier
    include Rails.application.routes.url_helpers

    def self.ransackable_attributes(auth_object = nil)
        Import.attribute_names
    end
  
    after_create_commit { broadcast_prepend_to "imports" }
    after_update_commit { broadcast_replace_to "imports" }
    after_destroy_commit { broadcast_remove_to "imports" }
  
    private

    def normalize_data_white_space
      attributes.each do |key, value|
        self[key] = value.squish if value.respond_to?(:squish)
      end
    end

end
