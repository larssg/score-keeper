# from http://blog.unquiet.net/archives/2005/11/06/helpful-rake-tasks-for-using-rails-with-subversion/

desc 'Configure Subversion for Rails'
task :configure_for_svn do
  system 'svn remove log/*'
  system "svn commit -m 'removing all log files from subversion'"
  system 'svn propset svn:ignore "*.log" log/'
  system 'svn update log/'
  system "svn commit -m 'Ignoring all files in /log/ ending in .log'"
  system 'svn propset svn:ignore "*.db" db/'
  system 'svn update db/'
  system "svn commit -m 'Ignoring all files in /db/ ending in .db'"
  system 'svn move config/database.yml config/database.example'
  system "svn commit -m 'Moving database.yml to database.example to provide a template for anyone who checks out the code'"
  system 'svn propset svn:ignore "database.yml" config/'
  system 'svn update config/'
  system "svn commit -m 'Ignoring database.yml'"
  system 'svn remove public/index.html'
  system 'svn remove public/images/rails.png'
  system "svn commit -m 'Removing public/index.html and public/images/rails.png'"
end

desc 'Add new files to subversion'
task :add_new_files do
  system "svn status | grep '^\?' | sed -e 's/? *//' | sed -e 's/ /\ /g' | xargs svn add"
end

desc 'shortcut for adding new files'
task add: [:add_new_files]
