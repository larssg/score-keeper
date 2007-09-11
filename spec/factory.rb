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
  
  def self.create_people(amount)
    people = []
    (1..amount).each do |number|
      people << Factory.create_person(:last_name => "Personson #{amount}")
    end
    people
  end
  
  def self.create_user(attributes = {})
    default_attributes = {
      :login => 'admin',
      :password => 'admin',
      :password_confirmation => 'admin',
      :email => 'admin@example.com'
    }
    User.create! default_attributes.merge(attributes)
  end
  
  def self.create_default_game
    people = Factory.create_people(4)
    
    game = Factory.create_game
    
    team_one = game.teams.create(:score => 10)
    team_one.memberships.create(:person_id => people[0])
    team_one.memberships.create(:person_id => people[1])
    
    team_two = game.teams.create(:score => 8)
    team_two.memberships.create(:person_id => people[2])
    team_two.memberships.create(:person_id => people[3])
    
    game
  end
end