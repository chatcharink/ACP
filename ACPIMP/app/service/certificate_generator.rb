class CertificateGenerator
    def initialize(registration)
        @registration = registration
    end

    def generate
        category_code = code.split("-")
        image = MiniMagick::Image.open(
            Rails.root.join("app/assets/images/certificate_template_#{award_text}_#{category_code[0].downcase}.png")
        )

        name_en = @registration.name_en.split(" ")
        name_en.map {|n| n.capitalize! }

        image.combine_options do |c|
            c.gravity "center"

            c.font Rails.root.join("app/assets/fonts/The-Seasons-Bold-Italic.ttf")

            # 🧑 ชื่อ
            c.pointsize 70
            c.draw "text 0, 30 '#{name_en.join(" ")}'"
            
            c.fill "#d7a534"
        end

        output_path = Rails.root.join("tmp/cert_#{@registration.id}.png")
        image.write(output_path)

        output_path
    end

    private

    def award_text
        @registration.award_text
    end

    def code
        @registration.category
    end
end