class Backend::RegistrationsController < Backend::BaseController
    def index
        return backend_competitions_path if session[:role] == "user"
        @registrations = Registration.all

        type = params[:competition_type] || "500"

        if params[:keyword].present?
            @registrations = @registrations.where("name_th LIKE ?", "%#{params[:keyword]}%")
        end

        if params[:status].present?
            @registrations = @registrations.where(status: params[:status])
        end

        if params[:competition_type].present?
            @registrations = @registrations.where(competition_type: type)
        end

        if params[:category].present?
            @registrations = @registrations.where(category: params[:category])
        end

        if params[:song_status].present?
            @registrations = @registrations.where(song_status: params[:song_status])
        end

        @sort = params[:sort] || "created_at"
        @direction = params[:direction] || "desc"

        @registrations = @registrations.order("#{@sort} #{@direction}")

        @registrations = @registrations.page(params[:page]).per(20)

        @category_groups = CategoryGroup.includes(:categories)

        if params[:partial]
            render partial: "table"
        else
            render :index
        end
    end

    def edit
        @registration = Registration.find(params[:id])
        @category_groups = CategoryGroup.includes(:categories)
    end

    def update
        begin
            @registration = Registration.find(params[:id])

            if @registration.update(registration_params)
                if params[:registration][:image].present?
                    @registration.image.attach(params[:registration][:image])
                end

                flash[:success] = "Update user succussfully"
                render json: { success: true, redirect_path: edit_backend_registration_path(@registration) }
            else
                p @registration.errors.full_message
                flash[:error] = "Fail to update user. Please try again later"
                render json: { success: false, errors: edit_backend_registration_path(@registration) }
            end
        rescue => e
            p e.message
            p e.backtrace.first
            flash[:error] = "Fail to update user. Please try again later"
            render json: { success: false, errors: edit_backend_registration_path(@registration) }
        end
    end

    def destroy
        begin
            register = Registration.find(params[:id]).destroy
            flash[:success] = "Delete user successfully."
        rescue => e
            flash[:error] = "Fail to delete user. Please try again later"
        end
        redirect_to backend_registrations_path
    end

    def approve
        r = Registration.find(params[:id])
        file_path = "#{Rails.root}/lib/banking.json"
        bank = {}
        if File.exist?(file_path)
            file = File.read(file_path)
            bank = JSON.parse(file)
        end

        if r.update(status: 1)
            ReceiptMailer.send_receipt(r, bank).deliver_now

            flash[:success] = "Approve registration of #{r.name_th} successfully"
        else
            flash[:error] = "Something went wrong. Please contact admin"
        end

        redirect_to backend_registrations_path
    end

    def reject
        r = Registration.find(params[:id])
        r.update(status: 2)
        flash[:success] = "Reject registration of #{r.name_th} succussfully"
        redirect_to backend_registrations_path
    end

    def approve_song
        r = Registration.find(params[:id])
        r.update(song_status: :approved)

        flash[:success] = "Approved song successfully"
        respond_to do |format|
            format.html { redirect_to backend_registrations_path }
            format.json { render json: { success: true } }
        end
    end

    def reject_song
        r = Registration.find(params[:id])
        r.update(song_status: :rejected)

        flash[:error] = "Rejected song successfully"
        respond_to do |format|
            format.html { redirect_to backend_registrations_path }
            format.json { render json: { success: true } }
        end
    end

    def receipt
        r = Registration.find(params[:id])

        file_path = "#{Rails.root}/lib/banking.json"
        bank = {}
        if File.exist?(file_path)
            file = File.read(file_path)
            bank = JSON.parse(file)
        end

        pdf = ReceiptGenerator.generate(r, bank)

        send_data pdf,
            filename: "receipt-#{r.code}.pdf",
            type: "application/pdf",
            disposition: "attachment"
    end

    private

    def registration_params
        update = params.require(:registration).permit(
            :name_th, :name_en, :phone, :email,
            :category, :competition_type, :song,
            :duration, :image
        )
        update[:phone] = update[:phone].gsub("-", "") if update[:phone].present?

        if update[:duration].present?
            min, sec = update[:duration].split(":").map(&:to_i)
            update[:duration] = min * 60 + sec
        end

        update
    end
end
