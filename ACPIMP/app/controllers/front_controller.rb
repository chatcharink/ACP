class FrontController < ApplicationController
    layout "front"

    def home
        @register = Registration.new()
        @settings = Setting.all
        @galleries = Gallery.order(:position)
        @category_groups = CategoryGroup.includes(:categories)

        file_path = "#{Rails.root}/lib/banking.json"
        
        @bank = {}
        if File.exist?(file_path)
            file = File.read(file_path)
            @bank = JSON.parse(file)
        end
    end
end
