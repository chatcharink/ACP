class Backend::UsersController < Backend::BaseController
    def index
        return backend_competitions_path if session[:role] == "user"
        @users = User.all

        @users = @users.where("firstname LIKE ? OR lastname LIKE ?", "%#{params[:q]}%", "%#{params[:q]}%") if params[:q].present?
        @users = @users.where(role: params[:role]) if params[:role].present?
        @users = @users.where(status: params[:status]) if params[:status].present?

        @users = @users.page(params[:page]).per(10)

        if params[:partial]
            render partial: "table"
        else
            render :index
        end
    end

    def show
    end
    
    def new
        @user = User.new
    end

    def create
        @user = User.new(user_params)

        if @user.save
            flash[:success] = "Created user successfully. Please try to login with username: #{params[:user][:username]}"
            
        else
            flash[:error] = "Cannot create user. Please try again later"
        end
        redirect_to backend_users_path
    end

    def edit
        @user = User.find(params[:id])
    end

    def update
        @user = User.find(params[:id])

        if @user.update(user_params)
            flash[:success] = "Updated user: #{params[:user][:username]} successfully."
        else
            flash[:error] = "Cannot update user. Please try again later"
        end
        redirect_to backend_users_path
    end

    def destroy
        user = User.find(params[:id])
        user.update(status: :deleted)

        redirect_to backend_users_path
    end

    private

    def user_params
        permitted = params.require(:user).permit(
            :username, :password, :firstname, :lastname, 
            :telephone, :email, :status, :role
        )

        if permitted[:password].blank?
            permitted.delete(:password)
        end

        permitted
    end
end
