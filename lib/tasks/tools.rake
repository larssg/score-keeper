namespace :tools do
  desc "Synchronize all sorts of things, such as db, schema in models, etc."
  task :sync => [ 'db:migrate', 'annotate_models' ]
  
  namespace :fix do
    desc "Update rankings"
    task :rankings => :environment do
      Game.reset_rankings
    end
  end
end