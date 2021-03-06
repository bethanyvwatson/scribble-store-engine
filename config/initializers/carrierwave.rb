#http://euglena1215.hatenablog.jp/entry/2017/01/07/134802
require 'carrierwave/storage/abstract'
require 'carrierwave/storage/file'
require 'carrierwave/storage/fog'

CarrierWave.configure do |config|
  
  #Use local storage if in development or test
  if Rails.env.development? || Rails.env.test?
    CarrierWave.configure do |config|
      config.storage = :file
    end
  end
  
  # Use AWS storage if in production
  if Rails.env.production?
    CarrierWave.configure do |config|
      config.fog_credentials = {
        :provider               => 'AWS',                             # required
        :aws_access_key_id      => ENV['AWS_ACCESS_KEY_ID'],            # required
        :aws_secret_access_key  => ENV['AWS_SECRET_ACCESS_KEY']     # required
      }
      config.storage = :fog
      config.fog_directory  = 'dot-me-scribbles'               # required
      config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
    end
  end

  if Rails.env.test? or Rails.env.cucumber?
    CarrierWave.configure do |config|
      config.storage = :file
      config.enable_processing = false
    end

    # use different dirs when testing
    CarrierWave::Uploader::Base.descendants.each do |klass|
      next if klass.anonymous?
      klass.class_eval do
        def cache_dir
          "#{Rails.root}/support/uploads/tmp"
        end

        def store_dir
          "#{Rails.root}/support/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
        end
      end
    end
  end
end