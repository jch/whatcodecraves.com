class PostsController < ApplicationController
  # Archive page
  #
  # @return [Hash] posts keyed by month and year. e.g. 'June 2012'
  def index
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
    unless @post = Post.from_permalink(params[:id])
      render nothing: true, status: 404
    end
  end

  # Raises an exception for testing 500's in test environment
  def error
    raise "something went wrong"
  end
end