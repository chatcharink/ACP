
class ReceiptGenerator
    require 'net/http'
    require 'json'

    def self.generate(registration, setting)
        
        uri = URI("https://raw.githubusercontent.com/kongvut/thai-province-data/refs/heads/master/api/latest/province.json")

        begin
            response = Net::HTTP.get(uri)
            provinces = JSON.parse(response)

            province = provinces.find { |p| p["id"].to_i == registration.province.to_i }
            
        rescue => e
            puts "เกิดข้อผิดพลาด: #{e.message}"
        end

        Prawn::Document.new(page_size: "A4") do |pdf|

            # พื้นหลัง (template png)
            pdf.image Rails.root.join("app/assets/images/receipt_template.png"),
                        at: [0, pdf.cursor],
                        width: pdf.bounds.width

            # ฟอนต์ (ถ้ามีไทย)
            pdf.font_families.update(
                "Sarabun" => {
                    normal: Rails.root.join("app/assets/fonts/Sarabun-Regular.ttf"),
                    bold: Rails.root.join("app/assets/fonts/Sarabun-Bold.ttf")
                }
            )

            pdf.font "Sarabun"

            # ข้อมูล
            # pdf.draw_text "Receipt No: #{registration.code}", at: [50, 500]
            pdf.draw_text "#{registration.name_th}", at: [80, 620], size: 8, style: :normal
            pdf.draw_text "อำเภอ#{registration.district} จังหวัด#{province["name_th"]}", at: [42, 607], size: 8, style: :normal
            pdf.draw_text "Tel: #{registration.phone}", at: [26, 595], size: 8, style: :normal

            pdf.draw_text "1", at: [43, 562], size: 8, style: :normal
            pdf.draw_text "ค่า สมัคร ACPIMC online", at: [80, 562], size: 8, style: :normal
            pdf.draw_text "1", at: [292, 562], size: 8, style: :normal
            pdf.draw_text "#{registration.competition_type}.00", at: [379, 562], size: 8, style: :normal
            pdf.draw_text "#{registration.competition_type}.00", at: [470, 562], size: 8, style: :normal

            pdf.draw_text "#{registration.competition_type}.00 บาท", at: [470, 515], size: 8, style: :normal
            pdf.draw_text "#{registration.competition_type}.00 บาท", at: [470, 501], size: 8, style: :normal

            pdf.draw_text "#{setting["bank_name"]}", at: [80, 175], size: 8, style: :normal
            pdf.draw_text "#{setting["account_no"]}", at: [240, 175], size: 8, style: :normal
            pdf.draw_text "#{registration.created_at.strftime("%d/%m/%Y")}", at: [355, 175], size: 8, style: :normal
            pdf.draw_text "#{registration.competition_type}.00 บาท", at: [450, 175], size: 8, style: :normal
        end.render
    end
end