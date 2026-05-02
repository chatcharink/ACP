class RegistrationsController < ApplicationController
    def search
        keyword = params[:keyword].to_s.strip
        return render json: [] if keyword.blank?

        q = Registration.all

        phone = keyword.gsub(/\D/, "")

        conditions = []
        values = {}

        # search ชื่อ
        conditions << "LOWER(name_th) LIKE :kw OR LOWER(name_en) LIKE :kw"
        values[:kw] = "%#{keyword.downcase}%"

        # search เบอร์
        if phone.present?
            conditions << "REPLACE(phone, '-', '') LIKE :phone"
            values[:phone] = "%#{phone}%"
        end

        q = q.where(conditions.join(" OR "), values)

        # if params[:category].present?
        #     q = q.where(category: params[:category])
        # end

        # if params[:competition_type].present?
        #     q = q.where(competition_type: params[:competition_type])
        # end

        results = q.order(created_at: :desc)

        render json: results.map { |r|
            has_competition = Score.where(registration_id: r.id).exists?
            award = Score.where(registration_id: r.id).sum(:value)
            if award >= 80
                competition_award = "Gold"
            elsif award > 70 && award <= 79
                competition_award = "Silver"
            elsif award > 60 && award <= 69
                competition_award = "Bronze"
            else
                competition_award = "-"
            end

            {
                id: r.id,
                name_th: r.name_th,
                name_en: r.name_en,
                category: r.category,
                type: r.competition_type,
                status: r.status,
                award: competition_award,
                has_competition: has_competition,
                is_reject: r.status.to_i == 2
            }
        }
    end

    def create
        @registration = Registration.new(registration_params)

        is_duplicate = Registration.where(name_en: params["registration"]["name_en"]).or(Registration.where(phone: params["registration"]["phone"]))
        if is_duplicate.blank?
            if @registration.save
                render json: { success: true }
            else
                flash[:error] = "Cannot register compentation. Please contact an admin"
                render json: { success: false, errors: root_path()}
            end
        else
            flash[:error] = "Name or phone number is duplicate. Please try again later"
            render json: { success: false, errors: root_path()}
        end
    end

    def update_slip
        begin
            registration = Registration.find(params[:id])

            if params[:upload_slip][:pay_slip].present?
                registration.update(pay_slip: params[:upload_slip][:pay_slip], status: 0)
            end

            flash[:success] = "Update payment slip successfully. Please waiting an admin to approve your application"
        rescue => e
            p e.message
            p e.backtrace.first
            flash[:error] = "Something went wrong. Please try again later"
        end
        redirect_to root_path
    end

    def download_comment
        registration = Registration.find(params[:id])

        pdf = CommentPdfGenerator.new(registration).generate

        send_data pdf.render,
                    filename: "comment_#{registration.id}.pdf",
                    type: "application/pdf",
                    disposition: "attachment"
    end

    def download_certificate
        registration = Registration.find(params[:id])

        file = CertificateGenerator.new(registration).generate

        send_file file,
                    filename: "certificate_#{registration.id}.png",
                    type: "image/png",
                    disposition: "attachment"
    end

    private

    def registration_params
        insert = params.require(:registration).permit(
            :name_th, :name_en, :category,
            :district, :province,
            :phone, :email,
            :song, :duration,
            :competition_type,
            :price, :vat, :total,
            :image, :pay_slip, :status
        )

        insert[:phone] = insert[:phone].gsub("-", "") if insert[:phone].present?
        insert[:status] = insert[:status].to_i
        insert[:song_status] = 0

        if insert[:duration].present?
            min, sec = insert[:duration].split(":").map(&:to_i)
            insert[:duration] = min * 60 + sec
        end

        insert
    end
end
