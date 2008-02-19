class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.string :name
      t.string :domain
      t.timestamps
    end
    
    add_column :users, :account_id, :integer
    add_column :games, :account_id, :integer
    add_column :teams, :account_id, :integer
    
    account = Account.create(:name => 'Default', :domain => 'default')
    User.update_all("account_id = #{account.id}")
    Game.update_all("account_id = #{account.id}")
    Team.update_all("account_id = #{account.id}")
  end

  def self.down
    remove_column :teams, :domain_id
    remove_column :games, :domain_id
    remove_column :users, :domain_id
    drop_table :accounts
  end
end