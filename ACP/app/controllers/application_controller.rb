class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  protect_from_forgery with: :null_session
  before_action :set_locale

  def set_locale
    I18n.locale = session[:lang] || :en
  end

  def switch_lang
    session[:lang] = params[:lang]
    redirect_back fallback_location: root_path
  end
end
