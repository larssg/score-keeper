class AccountNotifier < ActionMailer::Base
  def welcome(account)
    setup(account)
    @subject += 'Welcome to Score Keeper'
  end
  
  protected
  def setup(account)
    @subject = '[Score Keeper] ' 
    @body = { :account => account }
    @recipients = account.users.first.email
    @from = 'noreply@scorekeepr.dk' 
  end
end
