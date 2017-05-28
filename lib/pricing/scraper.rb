require 'open-uri'
require 'nokogiri'
require 'pricing'
require 'colored2'

module Joyent
  module Cloud
    module Pricing
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
            i      = 0
            self.doc.css('ul.full-specs').each do |ul|
              flavor = extract_price(ul)
              i      += 1
              next if flavor.cost.nil?
              config[flavor.name]= flavor.to_h
            end
            Joyent::Cloud::Pricing.log(:info, "found #{i.to_s.yellow.bold} elements of class #{'full-specs'.green}")
            config
          end

          private

          def numerical(price)
            price.gsub(/^\$/, '')
          end

          def extract_price(ul)
            # <ul class="full-specs">
            #     <li><strong>RAM</strong><span>0.25</span> GiB</li>
            #     <li><strong>CPU</strong><span>0.125</span> vCPU</li>
            #     <li><strong>Disk</strong><span>5</span> GB</li>
            #     <li><strong>API Name</strong><span>g4-highcpu-256M</span></li>
            #     <li class="mpph s"><strong>Hourly Price</strong><span>$0.0070</span> billed per minute</li>
            #     <li class="mpph s"><strong>Monthly Price</strong><span>$5.11</span> billed per minute</li>
            # [IGNORE]    <li class="mpph ws" style="display: none;"><strong>Hourly Price</strong><span>$0.0670</span> billed per minute</li>
            # [IGNORE]    <li class="mpph ws" style="display: none;"><strong>Monthly Price</strong><span>$48.91</span> billed per minute</li>
            # </ul>

            lis = ul.css('span').map(&:content)

            values        = {}
            values[:ram]  = lis[0]
            values[:cpus] = lis[1]
            values[:disk] = lis[2]
            values[:name] = lis[3]
            values[:cost] = numerical(lis[4])

            Flavor.new(values);
          end
        end
      end
    end
  end
end
