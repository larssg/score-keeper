namespace :tools do
  
  desc "Synchronize all sorts of things, such as db, schema in models, etc."
  task :sync => [ 'db:migrate', 'annotate_models' ]
  
end