require 'pricing'
require 'yaml'
namespace :joyent do
  namespace :pricing do
    desc "Refresh pricing configuration from the Joyent website"
    task :update do
      configuration = Joyent::Cloud::Pricing::Scraper.from_uri
      puts "downloading latest prices from #{Joyent::Cloud::Pricing::JOYENT_URL}"
      puts "saved #{configuration.config.keys.size} image prices to #{Joyent::Cloud::Pricing::DEFAULT_FILENAME}"
    end
  end
end
