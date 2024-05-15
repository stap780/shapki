class ApiImportVariantImages < ApplicationService
    require "open-uri"
    require "addressable/uri"
    require "image_processing/vips"
  
    #  FileUtils.rm_rf(Dir["#{Rails.public_path}/test_img/*"])
    #  FileUtils.rm_rf(Dir["#{Rails.public_path}/import_img/*"])
  
    def initialize(product_id, variant_id)
        Insale.api_init
        @product = Product.find(product_id)
        @variant = @product.variants.find(variant_id)
        @images_attributes = []
        ins_variant = InsalesApi::Variant.find(@variant.uid, params: {product_id: @product.uid})
        @images = ins_variant.image_ids
        @message = []
    end
  
    def call
      # create_tmp_folder
      if @images.present?
        io_image
        add_images_to_variant
        !@message.present? ? [true, "all_good"] : [false, @message]
      else
        [false, @message]
      end
      # clear_tmp_folder
    end
  
    private
  
    def create_tmp_folder
      FileUtils.mkdir_p(@tmp_folder_path)
    end
  
    def io_image
      variant_images_filenames = @variant.images.map { |im| im.file.filename.base }
      puts "ApiImportVariantImages ====== ApiImportVariantImages"
      puts variant_images_filenames
      @images.each_with_index do |image_ins_id, index|
        link = InsalesApi::Image.find(image_ins_id, params: {product_id: @product.uid}).original_url
        filename = File.basename(link)
        check_name = File.basename(link, File.extname(link))
        have_new_filename = !variant_images_filenames.include?(check_name)
  
        if have_new_filename
          hash = {}
          # temp_file_name = @product.id.to_s+"_"+(index+1).to_s+File.extname(link)
          tempfile = normalize_link_download_image_file(link) # , temp_file_name)
  
          images_have_position_like_index = @variant.images.pluck(:position).include?(index + 1)
  
          position = if images_have_position_like_index
            nil  # because we have validate_image_position callback
          else
            index + 1
          end
  
          hash[:position] = position
          hash[:uid] = image_ins_id
          file_data_hash = {}
          file_data_hash[:io] = tempfile # File.open(new_link)
          file_data_hash[:filename] = filename
          hash[:file] = file_data_hash
  
          # blob = ActiveStorage::Blob.create_and_upload!( io: File.open(new_link), filename: filename )
          # hash[:file] = blob.signed_id
          # hash[:position] = position
  
          @images_attributes.push(hash)
        end
      end
    end
  
    def add_images_to_variant
      puts "@images_attributes"
      puts @images_attributes
      @variant.update!(images_attributes: @images_attributes) if @images_attributes.present?
    end
  
    def clear_tmp_folder
      FileUtils.rm_rf(Dir[@tmp_folder_path + "*"])
    end
  
    def normalize_link_download_image_file(url) # , temp_file_name)
      clear_url = Addressable::URI.parse(url).normalize
  
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
        tempfile = ImageProcessing::Vips.source(file.path).saver!(quality: 90)
      end
    end
  
    def files_for_testing_volume(file_path, filename)
      # save original image to check volume for first 100 product pcs
      IO.copy_stream(file_path, "#{Rails.public_path}/test_img/#{filename}")
    end
  
end