require 'pricing/scraper'
require 'yaml'
namespace :joyent do
  namespace :pricing do
    desc "Refresh pricing configuration from the Joyent website"
    task :update do
      config = Joyent::Cloud::Pricing::Scraper.from_uri.config
      url    = Joyent::Cloud::Pricing::Scraper::JOYENT_URL
      file   = 'config/joyent_pricing.yml'
      puts "downloading latest prices from #{url}..."
      File.open(file, 'w') do |f|
        YAML.dump({:date => Time.now.to_s,
                   :url => url,
                   :pricing => config, }, f)
      end
      puts "saved #{config.keys.size} image prices to #{file}"
    end
  end
end
