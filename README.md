[![Build status](https://secure.travis-ci.org/kigster/joyent-cloud-pricing.png)](http://travis-ci.org/kigster/joyent-cloud-pricing)
[![Code Climate](https://codeclimate.com/github/kigster/joyent-cloud-pricing.png)](https://codeclimate.com/github/kigster/joyent-cloud-pricing)

# Joyent Cloud Pricing

Joyent currently does not provide API for getting prices of their images. It is available
on the website, but not anywhere else.

In addition, Joyent offers commit discounts to larger accounts that are willing to prepay and
commit to hardware for one or three years.  Such discounts are done case by case basis, and so
you would need to contact your Joyent account representative to get the details.

This gem encapsulating various tools around understanding Joyent pricing based on on-demand,
as well as commit pricing.  It works together with [knife-joyent](https://github.com/joyent/knife-joyent)
Chef plugin to show a detailed list of servers with pricing included.

## Installation

Add this line to your application's Gemfile:

    gem 'joyent-cloud-pricing'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install joyent-cloud-pricing

## Usage

Most recent pricing structure is stored in the YAML file under ```config/joyent_pricing.yml```.

To update this file, run provided rake task:

```ruby
rake joyent:pricing:update
```



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Author

Konstantin Gredeskoul, [@kig on twitter](http://twitter.com/kig), [@kigster on github](http://github.com/kigster)
