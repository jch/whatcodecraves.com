module Anemone
  module PageExtensions
    extend ActiveSupport::Concern

    included do
      alias_method :original_links, :links
      alias_method :links, :all_links
    end

    def add_urls(xpath, attribute)
      return unless doc
      doc.search(xpath).collect {|element|
        u = element[attribute]
        next if u.nil? or u.empty?
        abs = to_absolute(u) rescue next
        @links << abs if in_domain?(abs)
      }
      @links.uniq!
    end

    def all_links
      original_links
      add_urls('//img', 'src')
      @links
    end
  end
end

Anemone::Page.send(:include, Anemone::PageExtensions)