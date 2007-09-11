module Factory
  def self.create_game(attributes = {})
    default_attributes = {
      :played_at => 5.minutes.ago
    }
    Game.create! default_attributes.merge(attributes)
  end
  
  def self.create_person(attributes = {})
    default_attributes = {
      :first_name => 'Person',
      :last_name => 'Personson'
    }
    Person.create! default_attributes.merge(attributes)
  end
end