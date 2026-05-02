# app/services/bulk_comment_pdf.rb
class BulkCommentPdf
    require "prawn/table"
    
    def initialize(registrations)
        @registrations = registrations
    end

    def generate
        Prawn::Document.new(page_size: "A4", margin: 40) do |pdf|
        setup_font(pdf)

        @registrations.each_with_index do |r, index|
            render_registration(pdf, r)

            # 🔥 ขึ้นหน้าใหม่ ยกเว้นตัวสุดท้าย
            pdf.start_new_page unless index == @registrations.size - 1
        end
        end
    end

    private

    def setup_font(pdf)
        pdf.font_families.update(
        "thai" => {
            normal: Rails.root.join("app/assets/fonts/NotoSansThai-Regular.ttf"),
            bold:   Rails.root.join("app/assets/fonts/NotoSansThai-Bold.ttf")
        }
        )
        pdf.font "thai"
    end

    # -------------------------
    # 1 คน = 1 หน้า
    # -------------------------
    def render_registration(pdf, r)
        pdf.text "ใบประเมินการแข่งขัน",
        size: 20,
        style: :bold,
        align: :center

        pdf.move_down 10

        pdf.text "ชื่อ: #{r.name_th}", size: 14
        pdf.text "รุ่น: #{r.category}", size: 12

        pdf.move_down 10
        pdf.stroke_horizontal_rule

        # 👨‍⚖️ กรรมการ
        r.scores.group_by(&:user).each do |judge, scores|
        render_judge(pdf, judge, scores)
        end
    end

    # -------------------------
    # block กรรมการ
    # -------------------------
    def render_judge(pdf, judge, scores)
        pdf.move_down 10

        pdf.text "กรรมการ: #{judge.firstname} #{judge.lastname}",
        style: :bold

        pdf.move_down 5

        data = [["หัวข้อ", "คะแนน"]]

        scores.each do |s|
        data << [s.score_category.name, s.value.to_s]
        end

        total = scores.sum(&:value)
        data << ["รวม", total.to_s]

        pdf.table(data, width: pdf.bounds.width) do |t|
        t.row(0).font_style = :bold
        t.row(0).background_color = "eeeeee"
        t.columns(1).align = :right
        t.row(-1).font_style = :bold
        end

        # comment
        if scores.first.comment.present?
        pdf.move_down 5
        pdf.text "Comment: #{scores.first.comment}"
        end

        # image
        if scores.first.comment_file.attached?
        pdf.move_down 5
        pdf.image StringIO.new(scores.first.comment_file.download),
                    width: 150,
                    position: :center
        end

        pdf.move_down 5
        pdf.stroke_horizontal_rule
    end
end