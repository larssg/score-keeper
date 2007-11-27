namespace :tools do
  desc "Synchronize all sorts of things, such as db, schema in models, etc."
  task :sync => [ 'db:migrate', 'annotate_models' ]
  
  namespace :fix do
    desc "Update rankings"
    task :rankings => :environment do
      Game.reset_rankings
    end
  end
  
  namespace :fake_data do
    desc "Insert fake people"
    task :people => :environment do
      names = ['Al Pine', 'Barry Tone', 'Bill Board', 'Ed Cetera', 'Gene Ohme', 'Justin Case', 'Norm Al', 'Sal Uthe', 'Tim Berr', 'Wall Russ']
      names.each do |name|
        first_name, last_name = name.split
        Person.create(:first_name => first_name, :last_name => last_name)
      end
    end
  end
end