class Backend::CompetitionsController < Backend::BaseController
    def index
        # base = base.order("registrations.category ASC, name_th ASC")
        @registrations = filtered_registrations.page(params[:page]).per(20)
        # @registrations = base.page(params[:page]).per(20)
        @category_groups = CategoryGroup.includes(:categories)

        if params[:partial]
            render partial: "table"
        else
            render :index
        end
    end

    def filtered_registrations
        type = params[:competition_type] || "500"

        if session[:role] == "admin"
            base = Registration
                    .left_joins(:scores)
                    .where(competition_type: type, status: 1)
                    .select("
                        registrations.*,
                        COALESCE(SUM(scores.value), 0) AS total_score,
                        CASE 
                        WHEN COUNT(scores.id) > 0 THEN 'completed'
                        ELSE 'pending'
                        END AS competition_status
                    ")
                    .group("registrations.id")

        else
            base = Registration
                    .left_joins(:scores)
                    .where(competition_type: type, status: 1)
                    .where("scores.user_id = ?", session[:user_id].to_i )
                    .select("
                        registrations.*,
                        COALESCE(SUM(scores.value), 0) AS total_score,
                        CASE 
                        WHEN COUNT(scores.id) > 0 THEN 'completed'
                        ELSE 'pending'
                        END AS competition_status
                    ")
                    .group("registrations.id")
        end

        # filter
        base = base.where(category: params[:category]) if params[:category].present?

        if params[:q].present?
            q = "%#{params[:q]}%"
            base = base.where("registrations.name_th ILIKE ? OR registrations.name_en ILIKE ?", q, q)
        end

        if params[:competition_status].present?
            base = base.having(
                "CASE WHEN COUNT(scores.id) > 0 THEN 'completed' ELSE 'pending' END = ?",
                params[:competition_status]
            )
        end

        # 🏅 FILTER AWARD (คำนวณจาก score)
        if params[:award].present?
            case params[:award]
            when "gold"
                base = base.having("SUM(scores.value) >= 80")
            when "silver"
                base = base.having("SUM(scores.value) BETWEEN 70 AND 79")
            when "bronze"
                base = base.having("SUM(scores.value) BETWEEN 60 AND 69")
            end
        end

        # 🔥 SORT
        sort = params[:sort] || "score_desc"

        base = case sort
            when "score_desc"
                base.order("total_score DESC")
            when "score_asc"
                base.order("total_score ASC")
            when "name"
                base.order("registrations.name_th ASC")
            else
                base.order("registrations.name_th ASC")
            end
    end

    def new
        @registration = Registration.find(params[:registration_id])
        @categories = ScoreCategory.all

        @scores = @categories.map do |c|
            @registration.scores.find_or_initialize_by(
            user_id: session[:user_id],
            score_category: c
            )
        end

        render :edit
    end

    def create
        registration_id = params[:registration_id]

        Score.where(
            registration_id: registration_id,
            user_id: session[:user_id]
        ).delete_all

        total = 0

        params[:scores].each do |s|
            value = s[:value].to_i

            Score.create(
                registration_id: registration_id,
                user_id: session[:user_id],
                score_category_id: s[:category_id],
                value: value
            )

            total += value
        end

        # 🔥 comment + file
        score = Score.where(
            registration_id: registration_id,
            user_id: session[:user_id]
        ).first
        if params[:comment].present?
            score.comment = params[:comment]
        end

        if params[:file].present?
            score.comment_file.attach(params[:file])
            score.save
        end

        flash[:success] = "Give score succussfully."
        redirect_to backend_competitions_path
    end

    def edit
        @registration = Registration.find(params[:id])

        @scores = Score.where(
            registration_id: @registration.id,
            user_id: session[:user_id]
        )
        @categories = ScoreCategory.all
    end

    def admin_edit
        @registration = Registration.find(params[:id])
        @categories = ScoreCategory.all
        @judges = User.where(role: 1)

        @scores = @registration.scores.includes(:user, :score_category)
    end

    def update
        registration_id = params[:registration_id]

        params[:scores].each do |s|
            score = Score.find_by(
                registration_id: registration_id,
                user_id: session[:user_id],
                score_category_id: s[:category_id]
            )

            if score
                score.update(value: s[:value])
            else
                Score.create(
                    registration_id: registration_id,
                    user_id: session[:user_id],
                    score_category_id: s[:category_id],
                    value: s[:value]
                )
            end
        end

        score = Score.where(
            registration_id: registration_id,
            user_id: session[:user_id]
        ).first

        if params[:comment].present?
            score.comment = params[:comment]
        end

        if params[:file].present?
            score.comment_file.attach(params[:file])
            score.save
        end
    end

    def admin_update
        @registration = Registration.find(params[:id])
        begin
        # update score value
        if params[:scores]
            params[:scores].each do |_key, s|
                if s[:id].present?
                    score = Score.find(s[:id])
                    score.update(value: s[:value])
                else
                    Score.create(
                        registration_id: params[:id],
                        user_id: s[:judge_id],
                        score_category_id: s[:criterion_id],
                        value: s[:value]
                    )
                end
            end
        end

        # update comment per judge
        if params[:comment]
            params[:comment].each do |judge_id, comment|
            Score.where(registration_id: @registration.id, judge_id: judge_id)
                .update_all(comment: comment)
            end
        end

        # update image
        if params[:file].present?
            params[:file].each do |judge_id, file|

            # 👉 หา score ของ judge นี้ (ใช้ตัวแรกเป็นตัวเก็บไฟล์)
            score = Score.where(
                registration_id: params[:id],
                user_id: judge_id
            ).first

            # 👉 ถ้ายังไม่มี score เลย → สร้าง dummy
            if score.nil?
                score = Score.create(
                registration_id: params[:id],
                user_id: judge_id,
                score_category_id: ScoreCategory.first.id,
                value: 0
                )
            end

            score.comment_file.attach(file)
            end
        end
        
        flash[:success] = "Update score successfully"

        rescue => exception
            p exception.message
            p.exception.backtrace.first
            flash[:error] = "Cannot update score. Please contact administrator"
        end

        
        redirect_to backend_competitions_path
    end

    def score_pdf
        registration = Registration.find(params[:id])

        pdf = CommentPdfGenerator.new(registration).generate

        send_data pdf.render,
                    filename: "comment_#{registration.id}.pdf",
                    type: "application/pdf",
                    disposition: "attachment"
    end

    def certificate
        registration = Registration.find(params[:id])

        file = CertificateGenerator.new(registration).generate

        send_file file,
                    filename: "certificate_#{registration.id}.png",
                    type: "image/png",
                    disposition: "attachment"
    end

    def bulk_certificate
        # registrations = Registration.where(id: params[:ids])
        q = filtered_registrations

        if params[:ids].present?
            ids = params[:ids]
            q = q.where(id: ids).reorder(Arel.sql("FIELD(registrations.id, #{ids.join(',')})"))
            # q = q.where(id: ids)
        end

        registrations = q

        pdf = BulkCertificatePdf.new(registrations).generate

        send_data pdf.render,
                    filename: "certificates.pdf",
                    type: "application/pdf",
                    disposition: "attachment"
    end

    def bulk_comment
        # registrations = Registration
        #     .where(id: params[:ids])
        #     .includes(scores: [:user, :score_category])

        q = filtered_registrations

        if params[:ids].present?
            ids = params[:ids].split(",")
            q = q.where(id: ids).includes(scores: [:user, :score_category])
        end

        registrations = q

        pdf = BulkCommentPdf.new(registrations).generate

        send_data pdf.render,
                    filename: "comments.pdf",
                    type: "application/pdf",
                    disposition: "attachment"
    end

    def comment_template
        r = Registration.find(params[:id])

        pdf = CommentTemplatePdf.new(r).generate

        send_data pdf.render,
            filename: "comment_template_#{r.code}.pdf",
            type: "application/pdf",
            disposition: "attachment"
    end
end
