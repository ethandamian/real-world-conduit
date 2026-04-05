class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true,
            uniqueness: {case_sensitive: false},
            format: {with: URI::MailTo::EMAIL_REGEXP}

  validates :username, presence: true,
            uniqueness: {case_sensitive: false},
            length: {minimum: 3}

  before_save :downcase_email

  private
  def downcase_email
    self.email = self.email.downcase
  end
end
