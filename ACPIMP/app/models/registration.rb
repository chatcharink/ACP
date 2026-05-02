class Registration < ApplicationRecord
    has_one_attached :image
    has_one_attached :pay_slip

    validates :name_th, :phone, :competition_type, presence: true
    validates :phone, length: { minimum: 9 }
    validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
    validates :duration, numericality: { greater_than: 0 }
    enum song_status: { pending: 0, approved: 1, rejected: 2 }

    has_many :scores
    before_create :generate_code

    def generate_code
        prefix = category

        last = Registration.where(category: prefix).order(:created_at).last

        number = if last&.code.present?
            last.code.split("-").last.to_i + 1
        else
            1
        end

        self.code = "#{prefix}-#{number.to_s.rjust(3, "0")}"
    end

    def sum_score
        scores.sum(:value)
    end

    def award_level
        case sum_score
        when 80..Float::INFINITY then "gold"
        when 70...80 then "silver"
        when 60...70 then "bronze"
        else "none"
        end
    end

    def award_text
        award_level = "bronze" if award_level.blank?
        award_level
    end
end
