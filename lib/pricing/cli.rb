require 'mixlib/cli'

module Joyent
  module Cloud
    module Pricing
      class CLI
        include Mixlib::CLI

        banner 'Usage: joyent-price-helper [--commit <path-to-commit.yml] '

        option :config_file,
               short: '-c COMMIT_FILE',
               long: '--commit COMMIT_FILE',
               description: 'Path to the config file for commit pricing (YML), default is "config/commit_pricing.yml"',
               required: false

        option :help,
               short: '-h',
               long: '--help',
               description: 'Show this message',
               on: :tail,
               boolean: true,
               show_options: true,
               exit: 0

        attr_reader :args

        def run argv = ARGV
          parse_options(argv)
          raise "Not implemented just yet"
        end

      end
    end
  end
end

