class HomeController < ApplicationController
  # Homepage
  def index
    @posts = Post.recent(6)
  end
end