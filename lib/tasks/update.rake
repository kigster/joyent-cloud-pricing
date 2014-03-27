require 'pricing'
require 'yaml'
namespace :joyent do
  namespace :pricing do
    desc "Refresh pricing configuration from the Joyent website"
    task :update do
      load_from_url = Joyent::Cloud::Pricing::JOYENT_URL
      save_to_file = Joyent::Cloud::Pricing::PRICING_FILENAME

      STDOUT.puts "downloading latest prices from #{load_from_url}"
      config = Joyent::Cloud::Pricing::Configuration.from_url(load_from_url)
      config.save_yaml(save_to_file)
      STDOUT.puts "saved #{config.config.keys.size} image prices to #{save_to_file}"
    end
  end
end
