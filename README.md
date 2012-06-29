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
rails server
```

## Deployment

Staging [lives on heroku](http://whatcodecraves.herokuapp.com).

```sh
rake deploy          # runs everything under `deploy`
rake deploy:warmup   # warm up Rack::Cache by crawling the site
rake deploy:sitemap  # generate a sitemap
```

## TODO

* images
* import opperator posts
* migrate over disqus threads
* social buttons
* code overflow scroll
* caching, cascade store
* answer this question: http://stackoverflow.com/questions/5293361/on-ruby-on-rails-how-to-do-syntax-highlighting-using-markdown-rdiscount-blue
* deploy tasks
* helpers for linking to other articles
* might be better as a gem that allows overrides
* home#styleguide
* airbrake
* server-side syntax highlighting - done clientside w/ js right now