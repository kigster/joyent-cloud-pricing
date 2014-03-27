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
      class PriceTuple < Struct.new(:os, :cost, :flavor); end

      def result
        config = Hash.new
        self.doc.css("ul.full-specs").each do |ul|
          tuple = extract_price(ul)
          next if tuple.cost == "N/A"
          next if tuple.flavor =~ /kvm/ && tuple.os !~ /linux/i
          config[tuple.flavor]= tuple.cost.to_f
        end
        config
      end

      private

      def extract_price(ul)
        lis = ul.css("span").map(&:content)
        # grab last two <li> elements in each <ul class="full-spec"> block
        #PriceTuple.new(lis[-3], lis[-2].gsub(/^\$/, ''),  lis[-1])
        PriceTuple.new(lis[-3], lis[-2].gsub(/^\$/, ''),  lis[-1])
      end
    end
  end
end
