class User < ApplicationRecord
    has_secure_password

    enum status: {
        active: 0,
        inactive: 1,
        deleted: 2
    }

    enum role: {
        admin: 0,
        user: 1
    }

    validates :username, presence: true, uniqueness: true
    validates :password,
        length: { minimum: 6 },
        if: :password_present?

    validates :firstname, presence: true
    validates :lastname, presence: true
    validates :telephone, presence: true

    has_many :scores

    def password_present?
        password.present?
    end
end
