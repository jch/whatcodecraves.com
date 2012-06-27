xml.instruct! :xml, :version => "1.0"
xml.rss(:version => "2.0") {
  xml.channel {
    xml.title("WhatCodeCraves")
    xml.link("http://www.whatcodecraves.com/")
    xml.description("Jerry Cheung's portfolio and tech blog")
    xml.language('en-us')
    @posts.each do |month, posts|
      posts.each do |post|
        xml.item do
          xml.title(post.title)
          xml.description { xml.cdata!(post.description) }
          xml.author("Jerry Cheung")
          xml.pubDate(post.date.rfc822)
          xml.link(permalink_url(post.permalink))
        end
      end
    end
  }
}
