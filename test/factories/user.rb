Factory.sequence :user_login do |n|
  "user#{n}"
end

Factory.sequence :user_email do |n|
  "user#{n}@example.com"
end

Factory.define(:user) do |u|
  u.account_id { Factory(:account).id }
  u.login { Factory.next(:user_login) }
  u.email { Factory.next(:user_email) }
  u.password 'topsecret'
  u.password_confirmation 'topsecret'
  u.name 'Joe Smith'
  u.display_name 'Joe'
  u.time_zone 'Copenhagen'
end
