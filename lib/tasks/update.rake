require 'pricing'
require 'yaml'
namespace :joyent do
  namespace :pricing do
    desc "Refresh pricing configuration from the Joyent website"
    task :update do
      puts "downloading latest prices from #{Joyent::Cloud::Pricing::JOYENT_URL}"
      config = Joyent::Cloud::Pricing::Configuration.from_url
      config.save_yaml
      puts "saved #{config.config.keys.size} image prices to #{Joyent::Cloud::Pricing::PRICING_FILENAME}"
    end
  end
end
