class HomeController < ApplicationController
  # Homepage
  def index
    @posts = Post.recent(6)
  end

  # 404 Not found page
  def not_found
  end
end