class Backend::BaseController < ApplicationController
    allow_browser versions: :modern
    before_action :check_session_timeout
    protect_from_forgery with: :null_session
    before_action :require_login

    SESSION_TIMEOUT = 30.minutes

    def current_user
        @current_user ||= User.find_by(id: session[:user_id])
    end

    def require_login
        return if current_user
        return if controller_name == "sessions"
        redirect_to backend_login_path
    end

    helper_method :current_user

    private

    def check_session_timeout
        return unless session[:user_id]
        if session[:last_seen_at] &&
        session[:last_seen_at] < SESSION_TIMEOUT.ago
        reset_session
        redirect_to backend_login_path,
        alert: "Session expired"
        else
        session[:last_seen_at] = Time.current
        end
    end
end
