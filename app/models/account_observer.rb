class AccountObserver < ActiveRecord::Observer
  def after_create(account)
    AccountNotifier.deliver_welcome(account) if account.users.count > 0
  end
end
