require 'open-uri'
require 'nokogiri'

module Joyent::Cloud::Pricing
  class Scraper

    JOYENT_URL = "http://www.joyent.com/products/compute-service/pricing"

    # Class methods

    class << self
      def from_uri(uri = JOYENT_URL)
        new(parse_html_document(Nokogiri::HTML(open(uri))))
      end

      private

      def from_html_file filename
        new(parse_html_document(Nokogiri::HTML(File.read(filename))))
      end

      def parse_html_document doc
        mappings = Hash.new
        specs = doc.css("ul.full-specs")
        specs.each do |ul|
          lis = ul.css("span").map(&:content)
          # grab last two <li> elements in each <ul class="full-spec"> block
          os, cost, flavor = lis[-3], lis[-2].gsub(/^\$/, ''), lis[-1]
          next if cost == "N/A"
          next if flavor =~ /kvm/ && os !~ /linux/i

          mappings[flavor] = cost.to_f
        end

        mappings
      end
    end

    # Instance methods
    attr_accessor :config
    def initialize(hash = {})
      @config = hash
    end

    def [] value
      self.config[value]
    end

  end
end

