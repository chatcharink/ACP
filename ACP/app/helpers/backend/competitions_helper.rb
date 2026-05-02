module Backend::CompetitionsHelper
    def award_by_score(score)
        case score.to_i
            when 80..100 then "Gold"
            when 70...80 then "Silver"
            when 60...70 then "Bronze"
            else "-"
        end
    end

    def status_color(s)
        case s
        when 0 then "bg-gray-100 text-gray-500"
        when 1 then "bg-green-100 text-green-600"
        else "bg-red-100 text-red-600"
        end
    end

    def status_label(s)
        ["ยังไม่แข่ง","แข่งแล้ว","ตกรอบ"][s]
    end

    def award_by_score(score)
        case score.to_i
            when 80..100 then "Gold"
            when 70...80 then "Silver"
            when 60...70 then "Bronze"
            else "Participant"
        end
    end
end
