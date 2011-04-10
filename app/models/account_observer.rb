class AccountObserver < ActiveRecord::Observer
  def after_create(account)
    AccountMailer.welcome_message(account).deliver if account.users.count > 0
  end
end
