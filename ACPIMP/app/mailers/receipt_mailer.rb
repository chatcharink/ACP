class ReceiptMailer < ApplicationMailer
    def send_receipt(registration, bank)
        @registration = registration

        pdf = ReceiptGenerator.generate(@registration, bank)

        attachments["receipt_#{@registration.code}.pdf"] = pdf

        mail(
            to: @registration.email,
            subject: "Receipt for your registration"
        )
    end
end
