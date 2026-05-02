class Backend::SessionsController < Backend::BaseController
    layout "authen"

    def new
        redirect_to backend_dashboard_path() if session[:user_id].present?
    end

    def create
        user = User.find_by(username: params[:login][:username])

        if user&.authenticate(params[:login][:password]) && user.active?
            session[:user_id] = user.id
            session[:role] = user.role
            session[:firstname] = user.firstname
            flash[:success] = "Welcome #{user.firstname} #{user.lastname}"
            if user.role == "admin"
                redirect_to backend_dashboard_path
            else
                redirect_to backend_competitions_path
            end
        else
            flash[:error] = "Username or password incorrect. Please try again."
            redirect_to backend_login_path
        end
    end

    def destroy
        reset_session
        flash[:success] = "Logged out"
        redirect_to backend_login_path
    end
end
