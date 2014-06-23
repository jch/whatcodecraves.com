class PostsController < ApplicationController
  # Archive page
  #
  # @return [Hash] posts keyed by month and year. e.g. 'June 2012'
  def index
    @title = "Archived Posts"
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
      @title = @post.title
      fresh_when last_modified: @post.updated_at, public: true
    else
      render nothing: true, status: 404
    end
  end

  # Raises an exception for testing 500's in test environment
  def error
    raise "something went wrong"
  end
end
