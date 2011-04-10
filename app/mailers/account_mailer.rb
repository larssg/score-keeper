class AccountMailer < ActionMailer::Base
  default :from => "noreply@scorekeepr.dk"
  
  def send_welcome_message(account)
    @account = account
    
    mail(:to => account.users.first.email, :subject => '[Score Keeper] Welcome to Score Keeper')
  end
end