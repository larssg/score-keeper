# frozen_string_literal: true
Factory.define(:comment) do |c|
  c.association :user
  c.association :match
  c.body 'A test comment'
end