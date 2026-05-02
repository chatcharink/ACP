class Backend::SettingsController < Backend::BaseController
    before_action :set_settings
    require 'json'

    def show
        return backend_competitions_path if session[:role] == "user"
        @groups = CategoryGroup.includes(:categories)
        @galleries = Gallery.order(:position)

        file_path = "#{Rails.root}/lib/banking.json"
        @bank = {}
        if File.exist?(file_path)
            file = File.read(file_path)
            @bank = JSON.parse(file)
        end
        @score_categories = ScoreCategory.all
    end

    def update
        ActiveRecord::Base.transaction do
            
            @settings.update!(settings_params)

            if params[:groups]
                Category.destroy_all
                CategoryGroup.destroy_all

                params[:groups].each do |g|
                    group = CategoryGroup.create!(name_th: g[:name_th], name_en: g[:name_en])

                    g[:categories]&.each do |c|
                        Category.create!(name_th: c[:name_th], name_en: c[:name_en], code: c[:code], category_group_id: group.id)
                    end
                end
            end

            if params[:remove_gallery_ids]
                Gallery.where(id: params[:remove_gallery_ids]).destroy_all
            end

            if params[:gallery]
                params[:gallery].each do |img|
                    Gallery.create!(image: img)
                end
            end

            if params[:scores]
                params[:scores].each do |sc|

                    if sc[:id].present?
                        record = ScoreCategory.find(sc[:id])
                        record.update(
                            name: sc[:name],
                            max_score: sc[:max_score]
                        )
                    else
                        ScoreCategory.create(
                            name: sc[:name],
                            max_score: sc[:max_score]
                        )
                    end

                end
            end

            if params[:removed_score_ids].present?
                ScoreCategory.where(id: params[:removed_score_ids]).destroy_all
            end

            if params[:banking].present?
                data = {
                    bank_name: params[:banking][:bank_name],
                    account_no: params[:banking][:acc_no],
                    account_name: params[:banking][:acc_name]
                }

                File.open("#{Rails.root}/lib/banking.json", "w:UTF-8") do |f|
                    f.write(JSON.pretty_generate(data))
                end
            end
        end
        flash[:success] = "Update setting succussfully"
        render json: { success: true }
    rescue => e
        p e.message
        p e.backtrace.first
        flash[:error] = "Cannot update setting. Please contact admin"
        render json: { success: false }
    end

    private

    def set_settings
        @settings = Setting.first_or_create
    end

    def settings_params
        params.require(:settings).permit(
            :terms_th, :terms_en,
            :rules_online_th, :rules_online_en,
            :rules_onsite_th, :rules_onsite_en
        )
    end
end
