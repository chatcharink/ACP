# app/services/comment_template_pdf.rb
class CommentTemplatePdf
    require "prawn/table"

    def initialize(registration)
        @registration = registration
    end

    def generate
        Prawn::Document.new(page_size: "A4", margin: 40) do |pdf|
        setup_font(pdf)

        header(pdf)
        registration_info(pdf)

        pdf.move_down 15
        divider(pdf)

        pdf.move_down 15
        score_table(pdf)

        pdf.move_down 20
        comment_block(pdf)

        pdf.move_down 30
        signature_block(pdf)
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

    # ------------------------
    # HEADER
    # ------------------------
    def header(pdf)
        pdf.image Rails.root.join("app/assets/images/acp_logo2.png"),
                width: 70,
                position: :center

        pdf.move_down 10

        pdf.text "แบบฟอร์มประเมินการแข่งขัน",
        size: 20,
        style: :bold,
        align: :center

        pdf.move_down 5

        pdf.text "Competition Evaluation Form",
        size: 12,
        align: :center,
        color: "666666"
    end

    # ------------------------
    # INFO + IMAGE
    # ------------------------
    def registration_info(pdf)
        pdf.move_down 15

        pdf.bounding_box([0, pdf.cursor], width: pdf.bounds.width) do
        pdf.bounding_box([0, pdf.cursor], width: pdf.bounds.width / 2) do
            pdf.text "ชื่อ: #{@registration.name_th}", size: 12
            pdf.move_down 5
            pdf.text "Category: #{@registration.category}", size: 12
            pdf.move_down 5
            pdf.text "เพลง: #{@registration.song}", size: 12
        end

        if @registration.image.attached?
            pdf.bounding_box([pdf.bounds.width - 100, pdf.cursor + 50], width: 100) do
            pdf.image StringIO.new(@registration.image.download),
                        width: 100,
                        position: :right
            end
        end
        end
    end

    # ------------------------
    def divider(pdf)
        pdf.stroke_color "cccccc"
        pdf.stroke_horizontal_rule
        pdf.stroke_color "000000"
    end

    # ------------------------
    # TABLE (EMPTY)
    # ------------------------
    def score_table(pdf)
        data = [
        ["หัวข้อ / Criteria", "คะแนน / Score"]
        ]

        categories = ScoreCategory.all

        categories.each do |c|
        data << [c.name, ""]
        end

        data << ["รวม / Total", ""]

        pdf.table(data,
        header: true,
        width: pdf.bounds.width,
        cell_style: { padding: 8 }
        ) do |t|
        t.row(0).font_style = :bold
        t.row(0).background_color = "eeeeee"

        t.columns(1).align = :center
        t.columns(1).width = 100
        end
    end

    # ------------------------
    # COMMENT BLOCK
    # ------------------------
    def comment_block(pdf)
        pdf.text "Comment / ข้อเสนอแนะ",
        size: 14,
        style: :bold

        pdf.move_down 5

        5.times do
        pdf.stroke_horizontal_rule
        pdf.move_down 12
        end
    end

    # ------------------------
    # SIGNATURE
    # ------------------------
    def signature_block(pdf)
        pdf.move_down 20

        pdf.text "ลงชื่อกรรมการ / Judge Signature",
        align: :right

        pdf.move_down 40

        pdf.text ".................................................",
        align: :right
    end
end