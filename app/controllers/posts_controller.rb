class PostsController < ApplicationController
  helper_method :permalink_url

  # Archive page
  #
  # @return [Hash] posts keyed by month and year. e.g. 'June 2012'
  def index
    # TODO: the ordering of the hash is implicit here
    @posts = Post.all.inject({}) do |memo, post|
      key = post.date.strftime('%B %Y')
      memo[key] ||= []
      memo[key] << post
      memo
    end
  end

  # Find a Post by permalink, render as html
  #
  # @param [String] :id canonical post permalink
  def show
    @post = Post.new(params[:id])
    if @post.exists?
      fresh_when last_modified: @post.updated_at, public: true
    else
      render nothing: true, status: 404
    end
  end

  # Raises an exception for testing 500's in test environment
  def error
    raise "something went wrong"
  end

  # Returns fully qualified url for given permalink
  # @param [URI] permalink
  def permalink_url(permalink)
    uri = URI.parse(request.url)
    uri.path = '/articles' + permalink
    uri
  end
end