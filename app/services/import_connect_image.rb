class ImportConnectImage < ApplicationService
    require 'zip'

    def initialize(import_id)
        @import = Import.find(import_id)
        @destination = create_tmp_folder
        @files_path = []
        @message = []
    end

    def call
        puts "ImportConnectImage call"
        create_tmp_folder
        extract_zip
        process
        remove_tmp_folder
        !@message.present? ? [true, "all_good"] : [false, @message]
    end
  
    private

    def create_tmp_folder
        folder =  Rails.root.join("public", "import_#{@import.id.to_s}")
        FileUtils.mkdir_p(folder)
        @import.update(status: "create_tmp_folder") 
        folder
    end

    def remove_tmp_folder
        FileUtils.remove_dir(@destination)
        @import.update(status: "remove_tmp_folder") 
    end

    def process
        @import.update(status: "process") 
        @files_path.each do |link|
            hash = {}
            file_name = File.basename(link)
            position = file_name.include?('_') ? file_name.split('_').last : 1
            barcode = file_name.include?('_') ? file_name.split('_').first : nil
            variant = Variant.find_by_barcode(barcode)
            variant_images_filenames = variant.present? ? variant.images.map { |im| im.file.filename.base } : []

            check_name = File.basename(link, File.extname(link))
            have_new_filename = !variant_images_filenames.include?(check_name)

            if barcode && variant.present? && have_new_filename
                blob = ActiveStorage::Blob.create_and_upload!( io: File.open(link), filename: file_name )
                hash[:file] = blob.signed_id
                hash[:position] = position
                variant.update(images_attributes: [hash])
            end
        end
    end

    def extract_zip
        @import.file.open do |temp_file|
            Zip::File.open(temp_file) do |zip_file|
                zip_file.each do |f|
                    fpath = File.join(@destination, f.name.gsub(' ','_'))
                    FileUtils.mkdir_p(File.dirname(fpath))
                    zip_file.extract(f, fpath) unless File.exist?(fpath)
                    @files_path << fpath
                end
            end
        end
        @import.update(status: "extract_zip") 
    end

end

        # binary = @model.image.download

        # # or to create a file
        # include ActiveStorage::Downloading
        # tempfile = @model.image.download_blob_to_tempfile # (needs a blob method to be defined)

        # require 'zip'
        # temp_file = Rails.root.join("public", "photo_test.zip")
        # zip_file = Zip::File.open(temp_file)