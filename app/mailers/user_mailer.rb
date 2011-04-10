class UserMailer < ActionMailer::Base
  default :from => "noreply@scorekeepr.dk"
  
  def send_forgot_password_info(user)
    @user = user
    mail(:to => user.email, :subject => '[Score Keeper] Forgot password')
  end
end