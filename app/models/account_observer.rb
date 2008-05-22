class AccountObserver < ActiveRecord::Observer
  def after_create(account)
    AccountNotifier.deliver_welcome(account)
  end
end
