class Backend::DashboardController < Backend::BaseController
    def index
        return backend_competitions_path if session[:role] == "user"
        @online = build_data("500")
        @onsite = build_data("600")
    end

    private

    def build_data(type)
        scope = Registration.where(competition_type: type)

        {
            total: scope.count,
            confirmed: scope.where(status: 1).count,
            pending: scope.where(status: 0).count,

            # จำนวนต่อ category
            category_counts: scope.group(:category).count,

            # รวม duration (วินาที → นาที)
            category_duration: scope.group(:category).sum(:duration).transform_values { |v| (v / 60.0).round(2) }
        }
    end
end
