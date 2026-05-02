# app/services/comment_pdf_generator.rb
class CommentPdfGenerator
    require "prawn/table"
    
    def initialize(registration)
        @registration = registration
        @scores = registration.scores.includes(:user, :score_category)
    end

    def generate
        Prawn::Document.new(page_size: "A4", margin: 40) do |pdf|

            setup_font(pdf)
            pdf.image Rails.root.join("#{Rails.root}/app/assets/images/acp_logo2.png"), width: 80, position: :center
            header(pdf)
            registration_info(pdf)

            pdf.move_down 15
            divider(pdf)

            @scores.group_by(&:user).each_with_index do |(judge, scores), i|
                judge_section(pdf, judge, scores)

                pdf.start_new_page unless i == @scores.group_by(&:user).size - 1
            end

        end
    end

    private

    # ------------------------
    # FONT
    # ------------------------
    def setup_font(pdf)
        pdf.font_families.update(
            "thai" => {
                normal: Rails.root.join("app/assets/fonts/NotoSansThai-Regular.ttf"),
                bold:   Rails.root.join("app/assets/fonts/NotoSansThai-Bold.ttf")
            }
        )
        pdf.font "thai"
    end

    # ------------------------
    # HEADER
    # ------------------------
    def header(pdf)
        pdf.text "Comment จากคณะกรรมการ",
        size: 22,
        style: :bold,
        align: :center

        pdf.move_down 10
    end

    # ------------------------
    # REGISTRATION INFO
    # ------------------------
    def registration_info(pdf)
        pdf.text "ชื่อผู้เข้าแข่งขัน: #{@registration.name_th}", size: 14
        pdf.move_down 5
        pdf.text "รุ่น: #{@registration.category}", size: 12
    end

    # ------------------------
    # DIVIDER
    # ------------------------
    def divider(pdf)
        pdf.stroke_color "cccccc"
        pdf.stroke_horizontal_rule
        pdf.stroke_color "000000"
    end

    # ------------------------
    # JUDGE SECTION
    # ------------------------
    def judge_section(pdf, judge, scores)
        pdf.move_down 15

        pdf.text "กรรมการ: #{judge.firstname} #{judge.lastname}",
        size: 14,
        style: :bold

        pdf.move_down 8

        score_table(pdf, scores)

        pdf.move_down 10
        comment_block(pdf, scores)

        pdf.move_down 10
        image_block(pdf, scores)

        pdf.move_down 10
        divider(pdf)
    end

    # ------------------------
    # TABLE
    # ------------------------
    def score_table(pdf, scores)
        data = [["หัวข้อ", "คะแนน"]]

        scores.each do |s|
        data << [s.score_category.name, s.value.to_s]
        end

        total = scores.sum(&:value)
        data << ["รวม", total.to_s]

        pdf.table(data,
        header: true,
        width: pdf.bounds.width,
        cell_style: {
            padding: 8,
            borders: [:bottom]
        }
        ) do |t|

        # header style
        t.row(0).font_style = :bold
        t.row(0).background_color = "f0f0f0"

        # align score right
        t.columns(1).align = :right

        # total row
        t.row(-1).font_style = :bold
        end
    end

    # ------------------------
    # COMMENT
    # ------------------------
    def comment_block(pdf, scores)
        comment = scores.first.comment

        pdf.text "Comment:",
        style: :bold,
        size: 12

        pdf.move_down 3

        pdf.text(comment.presence || "-",
        size: 11,
        leading: 2)
    end

    # ------------------------
    # IMAGE
    # ------------------------
    def image_block(pdf, scores)
        file = scores.first.comment_file

        return unless file.attached?

        pdf.move_down 5

        pdf.text "ภาพประกอบ:",
        style: :bold,
        size: 12

        pdf.move_down 5

        pdf.image StringIO.new(file.download),
        width: 200,
        position: :center
    end

end