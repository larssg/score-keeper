class UserNotifier < ActionMailer::Base
  def forgot_password(user)
    setup(user)
    @subject += 'Forgot password'
  end

  protected
  def setup(user)
    @subject = '[Score Keeper] '
    @body = { :user => user }
    @recipients = user.email
    @from = 'noreply@scorekeepr.dk'
  end
end
