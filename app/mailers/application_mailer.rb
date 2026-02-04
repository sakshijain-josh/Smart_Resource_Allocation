class ApplicationMailer < ActionMailer::Base
  default from: "Smart Office Resource Manager <#{ENV.fetch('SMTP_USERNAME', 'notifications@resource-allocator.com')}>"
  layout "mailer"
end
