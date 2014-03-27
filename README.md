[![Gem Version](https://badge.fury.io/rb/joyent-cloud-pricing.png)](http://badge.fury.io/rb/joyent-cloud-pricing)
[![Build status](https://secure.travis-ci.org/kigster/joyent-cloud-pricing.png)](http://travis-ci.org/kigster/joyent-cloud-pricing)
[![Code Climate](https://codeclimate.com/github/kigster/joyent-cloud-pricing.png)](https://codeclimate.com/github/kigster/joyent-cloud-pricing)

# Joyent Cloud Pricing

This gem encapsulates several tools around understanding [Joyent](http://joyent.com) pricing model based on a combination of
on-demand, as well as commit pricing.  It works together with [knife-joyent](https://github.com/joyent/knife-joyent)
Chef plugin to show a detailed list of servers with pricing included.

## Introduction

Joyent *flavor* is a particular set of RAM, disk and CPU characteristics given to a virtual machine (zone).

Joyent is unique in that it's [SmartOS](http://smartos.org/) operating system allows dynamic resizing of it's zones without reboot.
This means that Joyent customers are much more likely going to be resizing on the fly their zones, so
it is common to start with one set of flavors, and end up with a completely different set down the road.

### Pricing API

Unfortunately Joyent currently does not provide API for getting prices of their packages (aka "flavors").
It is available on the website, but not anywhere else (yet).

### Commit Discounts

To make things even more complex, Joyent offers commit discounts to companies that are willing to prepay and
commit to hardware for one or three years.  Such discounts are done case by case basis, so
you would need to contact your Joyent account representative to get the details. These commits are
fixed by  flavor, so you would be committing to, say, 10 x ```g3-standard-64-smartos``` flavors for a year.

### The Problem

If you read the above, you understand that tracking your Joyent monthly pricing ends up being pretty
complicated process. This library was written to make this easier, and to allow users of Joyent Cloud
quickly check what their monthly pricing should be based on the current footprint, current on-demand
pricing, and optionally their pre-pay discounts.

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

## Full Pricing

Full price is stored in the configuration instance.

```ruby
Joyent::Cloud::Pricing::Configuration.instance["g3-standard-48-smartos"]
# => 1.536
```

## Analysis of Commit Pricing

Reserve pricing is meant to be defined by a YAML file, outside of the gem folder,
somewhere on the file system. File looks like this:

```yaml
defaults: &defaults
    years: 1

reserved:
  "g3-highcpu-32-smartos-cc":
    <<: *defaults
    prepay: 8000.00
    monthly: 500
    quantity: 10
  "g3-highmemory-17.125-smartos":
    <<: *defaults
    prepay: 800.00
    monthly: 60
    quantity: 12
  "g3-highio-60.5-smartos":
    <<: *defaults
    prepay: 1800.00
    monthly: 600
    quantity: 5
```

Each reserve defines the upfront component (per instance) ```prepay```, monthly pricing and quantity of the
reserved instances of this type/price.

Subsequently, analyzer can be used to analyze the current list of flavors in use versus commit, and
come up with recommendations and some calculations:

```ruby
# current list of flavors in use
flavors = %w(
    g3-highcpu-7-smartos
    g3-highcpu-7-smartos
    g3-highio-60.5-smartos
    g3-highio-60.5-smartos
    g3-highio-60.5-smartos
)
commit   = Joyent::Cloud::Pricing::Commit.from_yaml 'my_company/config/joyent-commit-pricing.yml'
analyzer = Joyent::Cloud::Pricing::Analyzer.new(commit, flavors)

analyzer.excess_monthly_price     # => monthly $$ for instances in excess of reserve
analyzer.over_committed_zone_list # => list of zones in reserve, but not in reality
```

## Command Line Tools

TBD.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Author

Konstantin Gredeskoul, [@kig on twitter](http://twitter.com/kig), [@kigster on github](http://github.com/kigster)
