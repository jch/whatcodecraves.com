# whatcodecraves.com

[![Build Status](https://secure.travis-ci.org/jch/whatcodecraves.com.png)](http://travis-ci.org/jch/whatcodecraves.com)

This is the content and Rails app that serves [whatcodecraves.com](http://whatcodecraves.com).
Articles are written in [markdown](http://daringfireball.net/projects/markdown/)
and stored in the `articles` folder.

## Overview

An article is a folder with a markdown document named `index.text`.
When an article is requested, it is rendered as html with the layout, and
cached. Cache expiration is based on file modification timestamps.

## Permalinks

The canonical permalink format is:

`/articles/YYYY/MM/DD/some-dasherized-title`

This will be matched against possible post paths. If a post cannot
be found, a 404 will be shown.

Legacy urls are 301 redirected by [DeprecatedRoutes](docs/DeprecatedRoutes.html)
middleware.

## Assets

Post assets served from `public`.

## Usage

There are utility rake tasks to manage posts and publishing:

```sh
rake articles:new      # write a new draft
rake articles:pending  # see pending unpublished drafts

rake util:crawl        # list all urls in site with status and referer
```

## Development

```sh
git clone https://github.com/jch/whatcodecraves.com
bundle
rake
yard
foreman start
```

## Documentation

Reference documentation can be found at [http://rubydoc.info/github/jch/whatcodecraves.com](http://rubydoc.info/github/jch/whatcodecraves.com).

## Deployment

Staging [lives on heroku](http://whatcodecraves.herokuapp.com).

```sh
rake deploy          # runs everything under `deploy`
rake deploy:warmup   # warm up Rack::Cache by crawling the site
rake deploy:sitemap  # generate a sitemap
```

Apache Passenger configuration on VPS:

```
# /etc/apache2/conf.d/passenger
LoadModule passenger_module /usr/local/rvm/gems/ruby-1.9.2-p180/gems/passenger-3.0.13/ext/apache2/mod_passenger.so
PassengerRoot /usr/local/rvm/gems/ruby-1.9.2-p180/gems/passenger-3.0.13
PassengerRuby /usr/local/rvm/wrappers/ruby-1.9.2-p180/ruby
```

To reload:

```sh
sudo service apache2 restart
```

## TODO

* server-side syntax highlighting - done clientside w/ js right now
* code overflow scroll
* helpers for linking to other articles
* gemify to separate code from content