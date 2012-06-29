class ApplicationController < ActionController::Base
  if Rails.env.production?
    rescue_from Exception do |e|
      render template: 'home/error', status: 500
    end
  end
end
