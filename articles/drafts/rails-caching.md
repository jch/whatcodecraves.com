# Rails Performance Deep Dive

You and your team worked hard to test, develop, and deploy your Rails app. The visual design is modern, the idea is interesting. On launch day, you happily watch as Twitter is a-buzz about your new app, and your realtime Google analytics begin lighting up like an early Christmas. Life is good. But wait! Half an hour in, you notice your analytics dropping like a rock. When you try and load your site, it's crawling and taking forever to load. Who do you call?
Read on for a pragmatic guide to tuning Rails applications.

### Knowing Is Half The Battle

Performance tuning is a blend of science and engineering. Science because it should be done methodically and in a controlled fashion; Engineering because tradeoffs dictate that not everything that can be optimized should be optimzed. The default knee jerk reaction of developers is to chase down one performance red flag without seeing the bigger picture of how a user perceives performance. For example, it's easy to fire up mysql and find the slowest query and optimize the snot of out it. But while that may be the slowest query, it may not be the most frequently accessed query. Heck, if view rendering time eclipses database access, then shaving a few milliseconds off a query just isn't worth it.

So before diving head first into code, take a step back and access the battlefield. It's actually really easy. Just install [NewRelic RPM](http://newrelic.com/). While it is a paid service to get more advanced features, it's free to start and worth every penny when you hit real traffic loads. With a combination of analytics and NewRelic, you'll be able to pinpoint the most accessed pages, and the slowest performing pages. NewRelic can also profile your development and staging environments so that you can catch problems before go-live.

### Performance Strategies

* Do the dumbest, simplest thing possible - debugging cache problems is hard
* Do time based expiry with revalidation even if content is fresh - fallback in case you're wrong
* Do HTTP caching before considering other cache strategies

Diagram of box with 4 sections, freshness on one axis, and speed on the other.

* slow bottleneck, ok for content to be slightly stale
* slow bottleneck, must be fresh always
* fast, ok to be stale
8 fast, must be fresh always

### Hmmmm, Low Hanging Fruit

The lowest of hanging fruits are the ones that don't change your application logic.

* static assets, sprockets fingerprinting
* cloudflare
* gzip response compression


### Performance Tests

The Ruby community loves to write tests. We write unit tests to verify individual components, and integration tests to verify the correctness of our system. Yet while speed is one of the most important features of web applications, the same testing fanaticism isn't applied to performance. [Performance Testing Rails Applications](http://guides.rubyonrails.org/performance_testing.html) is a good starting point for some built-in tools for testing.

### HTTP Caching

Staying with the idea of avoiding changes to application logic as much as possible, we identify the places in our application where we're duplicating work that we don't need to. For example, does your homepage need to go through the entire Rails stack every single time? What if you could reduce the number of calls to Rails to once every five minutes? If it's acceptable to have stale content for a short time interval, HTTP caching is a perfect fit.

In the case of our homepage, it's a simple matter of doing the following in the controller action:

```
def index
  # ...
  expires_in 5.minutes, :public => true
end
```

[expires_in](http://api.rubyonrails.org/classes/ActionController/ConditionalGet.html#method-i-expires_in) is a Rails helper method that sets the `Cache-Control` response header. To inspect the correct response headers are set, you can open the Network tab in Chrome or Firefox

TODO: add screenshot

For a great introduction of how HTTP caching works, check out Ryan Tomyako's article [Things Caches Do](http://tomayko.com/writings/things-caches-do). With those concepts in mind, I highly recommend reading over [RFC 2616](http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html) section about HTTP headers.

### Cache Stores

Some of you may be asking why I chose to use `expires_in` rather than use [caches_page](http://api.rubyonrails.org/classes/ActionController/Caching/Pages/ClassMethods.html#method-i-caches_page). While both of these methods accomplish the same result, I prefer to use HTTP caching because having the correct cache headers means that any intermediate caches can also cache your responses. This allows caches to interface with your app without knowing the underlying details of your implementation.

[ActiveSupport::Cache::Store](http://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html)

* configuration of cache stores
* tradeoffs and benefits of stores
* cascade cache store
* writing your own custom store

### Page Caching Impossible

Page caching is the holy grail of web optimizations. Once something is page cached, your backend server does nothing most of the time, occasionaly validates an incoming request/response as fresh, and very rarely goes through the entire Rails stack.

But what if your page can't be cached? A common example is if you have information specific to a user session on your pages.

But before we ditch page caching nirvana, take a look at how much of your page is specific to a user. If the answer is very little, then the page can still be a potential candidate for page caching.

Taking Hulu as an example, their homepage is mostly static with the exception of the user profile section in the upper navigation.

TODO: hulu screenshot

If they chose to page cache the homepage, then the first rendering would remember the profile information for a user. Unfortunately, later visitors would see that first user's profile information! That's a very bad thing.

But since the page is so close to being page-cachable, Hulu did a very clever thing. They cached the homepage, but rendered the profile section with a blank div. When a user logs in, they do an AJAX call to pull in just enough information to display that profile box.

### Fragment Caching

* when to use - single pagelet that needs to be realtime and inline in page (market summary)
* how to do time based expiry rather than manual expiry

### Performance Driven Architecture

The flow from a user's browser to a server in a classic web application looks like this:

browser -> cache proxies -> backend -> datastore -> rendering -> cache proxies -> browser

This model is simple to understand and well defined by the [HTTP protocol](http://www.w3.org/Protocols/rfc2616/)

But in this model, the majority of the heavy lifting is done by the backend server (request processing, data fetching, rendering html). An obvious method of increasing performance is doing less work. Depending on the application, it might make sense to move the responsibility of rendering and some of the business logic to the client side.

* frontend: Backbone.js, Spine, Ember.js
* backend: Grape, Sinatra, Rabl

Starting with an API driven architecture has multiple benefits:

* API available for client 3rd party developers
* API for custom mobile / native applications
* API removes responsibility of rendering

Possible downsides:

* SEO

### MySQL Performance Basics

(probably out of scope, but maybe a few pointers to get started)

* turn on profiling
* add indexes
* tune query cache
* tune buffer sizes

### Infrastructure

* nginx/apache configuration for serving static assets
* akamai/cloudflare
* reverse proxies: haproxy, varnish