Factory.define(:account) do |a|
  a.sequence(:name) { |n| "Account #{n}" }
  a.sequence(:domain) { |n| "domain#{n}" }
end