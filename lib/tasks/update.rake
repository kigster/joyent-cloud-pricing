require 'pricing'
require 'yaml'
namespace :joyent do
  namespace :pricing do
    desc 'Refresh pricing configuration from the Joyent website'
    task :update do
      load_from_url = Joyent::Cloud::Pricing::JOYENT_URL
      save_to_file = Joyent::Cloud::Pricing::PRICING_FILENAME
      old_config = Joyent::Cloud::Pricing::Configuration.default
      STDOUT.puts "downloading latest prices from #{load_from_url}"
      new_config = Joyent::Cloud::Pricing::Configuration.create(load_from_url)
      old_config.config.merge!(new_config.config)
      old_config.save_yaml(save_to_file)
      STDOUT.puts "saved #{old_config.config.keys.size} image prices to #{save_to_file}"
    end
  end
end
