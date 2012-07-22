class ApplicationController < ActionController::Base
  if Rails.env.production?
    rescue_from Exception do |e|
      Rails.logger.error(e)
      (e.backtrace || []).each do |line|
        Rails.logger.error(line)
      end
      notify_airbrake(e)
      render template: 'home/error', status: 500
    end
  end

  # @return [String] base url of request
  def base_url
    URI.parse(request.url).tap {|u| u.path = ''}.to_s
  end

  # @return [String] full url of request
  def full_url
    base_url + request.path
  end
end
