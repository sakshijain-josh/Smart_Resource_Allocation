class UserMailer < ApplicationMailer

  def welcome_email(user)
    @user = user
    @url  = 'http://localhost:3000/api/v1/auth/login'
    mail(to: @user.email, subject: 'Welcome to Smart Office Resource management System')
  end
end
