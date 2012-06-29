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
        new(path.dirname)
      end
    end
  end

  include Comparable

  # @!attribute [r] permalink
  # @return [String] relative canonical url
  attr_reader :permalink

  # @param [String] uri file path or uri path. e.g.
  #   /YYYY/MM/DD/dasherized-title
  #   /home/jch/articles/2011/11/14/articles_path/index.html
  def initialize(uri)
    @permalink = normalized_permalink(uri)
    @renderer  = Redcarpet::Markdown.new(Redcarpet::Render::XHTML, {
      no_intra_emphasis: true,
      fenced_code_blocks: true
    })
  end

  # Raw file contents of an index file
  #
  # @param [Pathname] dir directory to look for file
  # @return [String] index file contents. nil if not found
  def raw
    return nil unless directory
    @raw ||= directory.children.detect {|path|
      path.basename.to_s =~ /index.text/i
    }.read
  rescue Errno::ENOENT => e
    nil
  end

  # Normalizes directory names in `root_path` to find
  # a matching directory for the given permalink
  #
  # @return [Pathname] directory that holds permalink, nil if not found
  def directory
    # concatenate relative path to root_path
    dir, base  = (self.class.root_path + permalink.gsub(/^\//, '')).split
    normalized = base.to_s.upcase

    match = nil
    dir.find do |path|
      if path.basename.to_s.dasherize.upcase == normalized
        match = path
        Find.prune  # stop find
      end
    end
    @directory ||= match
  rescue Errno::ENOENT => e
    nil
  end

  # @return [Boolean] whether post directory exists with content
  def exists?
    !raw.nil?
  end

  # @return [String] title of post, first h1 line
  def title
    raw.split("\n").detect {|line|
      line =~ /\s/
    }.strip.gsub(/^#\s*/, '').gsub(/\s*#/, '')
  rescue => e
    raise Error.new(self, e.message)
  end

  # @return [String] publish date based on permalink
  def date
    Date.strptime permalink.match(%r{^/\d{4}/\d{2}/\d{2}})[0], '/%Y/%m/%d'
  end


  # @return [Datetime] last modified date
  def updated_at
    directory.atime
  end

  # @return [String] html excerpt of the post
  def description
    @parsed_html ||= Nokogiri::HTML(html)
    @parsed_html.css('p:first').to_s.strip
  end

  # @return [String] html of entire post
  def html
    @html ||= @renderer.render(raw)
  end

  # Compares posts by permalink
  def <=>(post)
    permalink <=> post.permalink
  end

  protected

  # Normalize a directory path to a permalink string
  #
  # @param [Pathname, String] path
  # @return [String] permalink
  def normalized_permalink(path)
    path.to_s.
      gsub(self.class.root_path.to_s, '').   # relative path
      gsub(/[_,!@#\$^*?]/, '-').  # dasherize
      gsub(/index\.html$/, '').   # remove trailing index.html
      gsub(/\/$/, '').            # remove trailing /
      downcase
  end
end