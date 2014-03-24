[![Build status](https://secure.travis-ci.org/kigster/joyent-cloud-pricing.png)](http://travis-ci.org/kigster/joyent-cloud-pricing)
[![Code Climate](https://codeclimate.com/github/kigster/joyent-cloud-pricing.png)](https://codeclimate.com/github/kigster/joyent-cloud-pricing)

# Joyent Cloud Pricing

This gem encapsulates several tools around understanding [Joyent](http://joyent.com) pricing model based on a combination of
on-demand, as well as commit pricing.  It works together with [knife-joyent](https://github.com/joyent/knife-joyent)
Chef plugin to show a detailed list of servers with pricing included.

## Problem

Joyent *flavor* is a particular set of RAM, disk and CPU characteristics given to a virtual machine (zone).

Joyent is unique in that it's [SmartOS](http://smartos.org/) operating system allows dynamic resizing of it's zones without reboot.
This means that Joyent customers are much more likely going to be resizing on the fly their zones, so
it is common to start with one set of flavors, and end up with a completely different set down the road.

Unfortunately Joyent currently does not provide API for getting prices of their packages (aka "flavors").
It is available on the website, but not anywhere else (yet).

To make things even more complex, Joyent offers commit discounts to companies that are willing to prepay and
commit to hardware for one or three years.  Such discounts are done case by case basis, so
you would need to contact your Joyent account representative to get the details. These commits are
fixed by the flavor, so you could be committing to, say, 10 "g3-standard-64-smartos" flavors for a year.




## Problem

Imagine you prepaid for 50 nodes. Then you added 48 nodes that are on-demand. Then you resized some
of the

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
