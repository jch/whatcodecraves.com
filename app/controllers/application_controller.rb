class ApplicationController < ActionController::Base
  rescue_from Exception do |e|
    render template: 'home/error', status: 500
  end
end
