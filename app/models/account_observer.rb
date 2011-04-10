class AccountObserver < ActiveRecord::Observer
  def after_create(account)
    AccountMailer.send_welcome_message(account) if account.users.count > 0
  end
end
