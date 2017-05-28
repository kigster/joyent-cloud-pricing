[![Gem Version](https://badge.fury.io/rb/joyent-cloud-pricing.png)](http://badge.fury.io/rb/joyent-cloud-pricing)
[![Build status](https://secure.travis-ci.org/kigster/joyent-cloud-pricing.png)](http://travis-ci.org/kigster/joyent-cloud-pricing)
[![Code Climate](https://codeclimate.com/github/kigster/joyent-cloud-pricing.png)](https://codeclimate.com/github/kigster/joyent-cloud-pricing)
[![Coverage Status](https://coveralls.io/repos/kigster/joyent-cloud-pricing/badge.png?branch=master)](https://coveralls.io/r/kigster/joyent-cloud-pricing?branch=master)

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

To update this file using prices published on Joyent's website, run the provided rake
task, and if YAML file changed, please feel free to submit a pull request.

```ruby
rake joyent:pricing:update
```

### Full Pricing

Full price is stored in the configuration instance and is read from YAML file.

```ruby
c = Joyent::Cloud::Pricing::Configuration.default
f = c.flavor "g3-highmemory-34.25-kvm"
f.to_h
# => {:name=>"g3-highmemory-34.25-kvm", :os=>"Linux",
#     :cost=>0.817, :cpus=>4.0, :disk=>843, :ram=>34.25}
f.name
# => "g3-highmemory-34.25-kvm"
```

### Analysis of Commit Pricing

>  DISCLAIMER: please note that prices specified in this sample commit configuration
>  are completely arbitrary and have no relationship to any actual discounts issued by Joyent, Inc.

Reserve pricing is meant to be defined by a YAML file, outside of the gem folder,
somewhere on the file system. File looks like this.

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

analyzer.monthly_overages_price   # => monthly $$ for instances in excess of reserve
analyzer.over_reserved_zone_list  # => list of zones in reserve, but not in reality
```

### Custom Pricing

If you have some zones with flavors that are either old, or created specifically for you,
they may not be known to this library.  If they are known to you, you can use the reserve
pricing YAML file, and add a 'custom' section to it to define prices (and other attributes)
for any of the custom flavors, as follows (note that the 'reserved' section is not required).

```yaml
defaults: &defaults
    years: 1

custom:
  :flavor-just-for-me:
    :cost: 1.22
    :disk: 800
    :ram: 96
    :cpus: 32

```

The structure is the same as in the main file ```joyent_pricing.yml```, and the contents will
simply be merged on top of Joyent's standard pricing, so you can even overwrite existing flavors.

### On Demand Discounts

If (hypothetically speaking) you were able to negotiate a flat percentage discount off the on-demand
rates, you could add the following to the commit pricing file:

```yaml
defaults: &defaults
    years: 1

discount:
    type: :percent
    value: 5
```

This would apply %5 discount to all on-demand rates.  Any reserve pricing would not be affected.

### Reporter

This module is used by ```knife joyent server price``` plugin to calculate pricing with and without
reserve discounts.

```ruby
current_zone_list = %w(g3-highcpu-8-smartos g3-highcpu-8-smartos )

reporter          = Joyent::Cloud::Pricing::Reporter.new(
                      'config/reserve-commit.yml',
                       current_zone_list)

puts reporter.render
```

Example output with commit pricing used:

```
Joyent Pricing Calculator: https://github.com/kigster/joyent-cloud-pricing
.................................................................
ZONE COUNTS:
  Total # of zones                                             33
  Total # of reserved zones                                    27
  Total # of reserved but absent flavors                        6
      4 x g3-highmemory-68.375-smartos
      2 x g3-highcpu-7-smartos
.................................................................

  Resources in use:      Reserved       On-Demand           Total
           CPUs               384             118             494
           RAM               828G            140G            907G
           DISK               23T              5T             27T

MONTHLY COSTS:
  List of on-demand flavors by price (in excess of reserve)

      2 x g3-highcpu-32-smartos-cc                      $3,339.36
      2 x g3-highcpu-16-smartos                         $1,670.40
      2 x g3-highcpu-7-smartos                            $731.52
      1 x g3-standard-30-smartos                          $691.20
                                                      ___________
  On demand monthly                                     $6,432.48
  Zones under reserve pricing                           $8,720.00
                                                      ___________
  Total                                                $15,152.48
.................................................................

YEARLY COSTS:
  On demand yearly                                     $77,189.76
  Reserve prepay one time fee                          $98,600.00
  Reserve sum of all monthly fees                     $104,640.00
                                                      ___________
  Total                                               $280,429.76

YEARLY RESERVE SAVINGS:
  Savings due to reserved pricing                     $145,522.24
  Savings %                                                   34%
.................................................................
```

### Color

You can turn off color output by setting ```NO_COLOR``` environment variable.

### Usage with knife joyent

This gem is integrated into [knife-joyent](https://github.com/joyent/knife-joyent) gem.

Use it with ```knife joyent``` as follows:

```
knife joyent server pricing -z -r config/my-reserve-config.yml [ --no-color ]
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Disclaimer

> This gem is provided as a convenience tool in understanding and comparing cloud pricing. No warranties,
> explicit or implied, are made in relation to correctness or accuracy of the calculations provided by this
> library. Use at your own risk.

## Author

* Konstantin Gredeskoul, [@kig on twitter](http://twitter.com/kig), [@kigster on github](http://github.com/kigster)
