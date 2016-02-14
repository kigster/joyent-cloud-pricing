require 'open-uri'
require 'nokogiri'

module Joyent::Cloud::Pricing
  class Scraper
    def scrape(url = JOYENT_URL)
      Parser.new(Nokogiri::HTML(open(url))).result
    end

    def load_from_file(file)
      Parser.new(Nokogiri::HTML(File.read(file))).result
    end

    class Parser < Struct.new(:doc)

      def result
        config = Hash.new
        i = 0
        self.doc.css('ul.full-specs').each do |ul|
          flavor = extract_price(ul)
          i += 1
          next if flavor.cost.nil?
          config[flavor.name]= flavor.to_h
        end
        puts "Found #{i} elements of class 'full-specs'"
        config
      end

      private

      def extract_price(ul)
        lis = ul.css("span").map(&:content)
        # grab last two <li> elements in each <ul class="full-spec"> block
        # and first few for cpu/ram/disk
        # note: this obviously depends on Joyent website markup and is subject to break.
        Flavor.new(lis[-1], # flavor
                   os: lis[-3],
                   cost: lis[-2].gsub(/^\$/, ''),
                   ram: lis[0],
                   cpus: lis[1],
                   disk: lis[2])
      end
    end
  end
end
