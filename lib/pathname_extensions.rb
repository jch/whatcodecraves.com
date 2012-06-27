require 'pathname'

# TODO: do we want this to work with files as well as directories?
module PathnameExtensions
  def self.included(base)
    base.class_eval do
      include Enumerable
    end
  end

  def each
    return children.each unless block_given?
    children.each do |path|
      yield path
    end
  end

  def post?
    !!(directory? && children.detect {|e| e.basename.to_s =~ /index/i})
  end

  # Search a directory
  #
  # @param [String,Regexp] query
  # @param [Block] predicate called with each path. return true if matched
  #
  def search(query = nil, predicate = nil)
    matches = []
    query   = Regexp.new(query) if query
    find {|path|
      matched = !query || query.match(path.to_s)
      matched = false if path == self
      matches << path if predicate && predicate.call(path) || matched
    }
    matches
  end
end

Pathname.send(:include, PathnameExtensions)