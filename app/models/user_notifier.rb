class UserNotifier < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new account'
  
    @body[:url]  = "http://10.0.0.13:3000/activate/#{user.activation_code}"
  
  end
  
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "http://10.0.0.13:3000/"
  end
  
  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "scorekeeper@larssehested.com"
      @subject     = "[ScoreKeeper] "
      @sent_on     = Time.now
      @body[:user] = user
    end
end
