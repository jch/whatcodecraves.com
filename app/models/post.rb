require 'date'
require 'pathname_extensions'

# A blog post is a directory with an index.text document found within `root_path`.
class Post
  class Error < StandardError
    attr_reader :post
    def initialize(post, message)
      @post = post
      super("#{post.permalink}: #{message}")
    end
  end

  class << self
    # @!attribute [rw] root_path
    #   Pathname to directory to store and retrieve posts.
    #   Default `Rails.root`.
    #   @return [Pathname]
    attr_writer :root_path
    def root_path
      @root_path ||= Rails.root + 'articles'
      @root_path ||= Pathname.new(@root_path.expand_path)
    end

    # @param [Integer] count number of recent posts to return
    # @return [Array] count most recent posts
    def recent(count = 6)
      all.slice(0, count)
    end

    # @return [Array] posts found under `root_path`
    def all
      root_path.search('index.text').sort {|a,b| b <=> a}.map do |path|
        from_path(path.dirname)
      end
    end

    # Initialize a Post from a pathname
    #
    # @param [Pathname, String] path
    # @return [Post] nil if not found
    def from_path(path)
      path = Pathname.new(path).expand_path
      return nil unless path.directory?

      permalink = article_permalink(path)
      content   = article_content(path)
      content ? Post.new(permalink, content) : nil
    end

    # Initialize a Post from a given permalink
    # Permalinks are in the format: /YYYY/MM/DD/dasherized-title
    #
    # @param [String] permalink
    # @return [Post] nil if not found
    def from_permalink(permalink)
      dir     = article_dir(permalink)
      content = article_content(dir) if dir
      content ? Post.new(permalink, content) : nil
    end

    # Normalize a directory path to a permalink string
    #
    # @param [Pathname, String] path
    # @return [String] permalink
    def article_permalink(path)
      path.to_s.
        gsub(root_path.to_s, '').   # relative path
        gsub(/[_,!@#\$^*?]/, '-').  # dasherize
        gsub(/index\.html$/, '').   # remove trailing index.html
        gsub(/\/$/, '').            # remove trailing /
        downcase
    end

    # Normalizes directory names in `root_path` to find
    # a matching directory for the given permalink
    #
    # @param [String] permalink
    #
    # @return [Pathname] directory that holds permalink, nil if not found
    def article_dir(permalink)
      # concatenate relative path to root_path
      dir, base  = (root_path + permalink.gsub(/^\//, '')).split
      normalized = base.to_s.upcase

      match = nil
      dir.find do |path|
        if path.basename.to_s.dasherize.upcase == normalized
          match = path
          Find.prune  # stop find
        end
      end
      match
    rescue Errno::ENOENT => e
      nil
    end

    # Raw file contents of an index file if it's found in `dir`
    #
    # @param [Pathname] dir directory to look for file
    # @return [String] index file contents. nil if not found
    def article_content(dir)
      dir.children.detect {|path|
        path.basename.to_s =~ /index.text/i
      }.read
    rescue Errno::ENOENT => e
      nil
    end
  end

  include Comparable

  # @!attribute [r] permalink
  # @return [String] relative canonical url
  attr_reader :permalink

  # @!attribute [r] raw
  # @return [String] raw content of markdown document
  attr_reader :raw

  # @param [String] permalink canonical relative url for post
  # @param [String] raw markdown content
  def initialize(permalink, raw)
    @permalink = permalink
    @raw       = raw
    @renderer  = Redcarpet::Markdown.new(Redcarpet::Render::XHTML, {
      no_intra_emphasis: true,
      fenced_code_blocks: true
    })
  end

  # @return [String] title of post, first h1 line
  def title
    @raw.split("\n").detect {|line|
      line =~ /\s/
    }.strip.gsub(/^#\s*/, '').gsub(/\s*#/, '')
  rescue => e
    raise Error.new(self, e.message)
  end

  # @return [String] publish date based on permalink
  def date
    Date.strptime permalink.match(%r{^/\d{4}/\d{2}/\d{2}})[0], '/%Y/%m/%d'
  end

  # @return [String] html excerpt of the post
  def description
    @parsed_html ||= Nokogiri::HTML(html)
    @parsed_html.css('p:first').to_s.strip
  end

  # @return [String] html of entire post
  def html
    @html ||= @renderer.render(@raw)
  end

  # Compares posts by permalink
  def <=>(post)
    permalink <=> post.permalink
  end
end