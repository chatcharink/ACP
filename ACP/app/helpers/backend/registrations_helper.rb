module Backend::RegistrationsHelper
    def status_badge(status)
        case status
        when 1
            "<span class='px-2 py-1 bg-green-100 text-green-700 rounded-full text-xs'>ยืนยันแล้ว</span>".html_safe
        when 2
            "<span class='px-2 py-1 bg-red-100 text-red-600 rounded-full text-xs'>ปฏิเสธ</span>".html_safe
        else
            "<span class='px-2 py-1 bg-yellow-100 text-yellow-700 rounded-full text-xs'>รอยืนยัน</span>".html_safe
        end
    end

    def sort_icon(column, current_sort, direction)
        if current_sort == column
            if direction == "asc"
                '<svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 15l7-7 7 7" /></svg>'.html_safe
            else
                '<svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" /></svg>'.html_safe
            end
        else
            '<svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7l4-4 4 4M8 17l4 4 4-4" /></svg>'.html_safe
        end
    end

    def format_duration(sec)
        return "" unless sec

        m = sec / 60
        s = sec % 60

        "%02d:%02d" % [m, s]
    end
end
