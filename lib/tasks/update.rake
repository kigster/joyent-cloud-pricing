require 'pricing/scraper'
task :update do |t, args|
  Joyent::Cloud::Pricing::Scraper.new
end
