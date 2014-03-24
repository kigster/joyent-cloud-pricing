require 'pricing'
require 'yaml'
namespace :joyent do
  namespace :pricing do
    desc "Refresh pricing configuration from the Joyent website"
    task :update do
      puts "downloading latest prices from #{Joyent::Cloud::Pricing::JOYENT_URL}"
      configuration = Joyent::Cloud::Pricing::Scraper.from_uri
      configuration.save_yaml
      puts "saved #{configuration.config.keys.size} image prices to #{Joyent::Cloud::Pricing::PRICING_FILENAME}"
    end
  end
end
