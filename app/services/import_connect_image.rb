class ImportConnectImage < ApplicationService
    require "open-uri"
    require "addressable/uri"

    def initialize(import_id)
        @import = Import.find(import_id)

    end

    def call
      puts "ImportConnectImage call"
    #   load_file_to_s3 if !@import.file.attached?
      process
      !@message.present? ? [true, "all_good"] : [false, @message]
    end
  
    private

    def process


    end

    def load_file_to_s3
        clear_url = Addressable::URI.parse(@import.link).normalize
  
        begin
            file = URI.open(clear_url.to_s)
        rescue OpenURI::HTTPError
            puts "normalize_download_image_file OpenURI::HTTPError"
            puts clear_url
            file = nil
        rescue Net::OpenTimeout
            puts "normalize_download_image_file Net::OpenTimeout"
            puts clear_url
            file = nil
        else
            file_name = File.basename(@import.link)
            @import.file.attach(io: file, filename: file_name)
        end

    end

end