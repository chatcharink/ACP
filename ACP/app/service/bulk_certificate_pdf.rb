class BulkCertificatePdf
    def initialize(registrations)
        @registrations = registrations
    end

    def generate
        Prawn::Document.new(page_size: "A4", margin: 0, page_layout: :landscape) do |pdf|
            @registrations.each_with_index do |r, index|

                # 🔥 generate PNG เกียรติบัตร
                image_path = CertificateGenerator.new(r).generate

                # 🔥 ใส่เต็มหน้า
                pdf.image image_path,
                        fit: [pdf.bounds.width, pdf.bounds.height],
                        position: :center,
                        vposition: :center

                # 🔥 หน้าใหม่
                pdf.start_new_page unless index == @registrations.size - 1
            end
        end
    end
end