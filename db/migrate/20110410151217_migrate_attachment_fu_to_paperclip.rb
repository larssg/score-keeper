class MigrateAttachmentFuToPaperclip < ActiveRecord::Migration
  def self.up
    add_column :users, :avatar_file_name, :string
    add_column :users, :avatar_content_type, :string
    add_column :users, :avatar_file_size, :integer
    add_column :users, :avatar_updated_at, :datetime
    
    User.reset_column_information
    User.all.each do |user|
      next if user.mugshot_id.blank?
      
      mugshot = Mugshot.find(user.mugshot_id)
      next if mugshot.blank?
      
      user.avatar_file_name = mugshot.filename
      user.avatar_content_type = mugshot.content_type
      user.avatar_file_size = mugshot.size
      
      old_path = File.join(Rails.root, 'public', mugshot.public_filename)
      new_path = user.avatar.path(:original)
      new_folder = File.dirname(new_path)
      
      unless File.exists?(new_folder)
        FileUtils.mkdir_p(new_folder)
      end
      
      if File.exists?(old_path)
        puts "Moving #{old_path} to #{new_path}"
        FileUtils.cp(old_path, new_path)
        user.save
        user.avatar.reprocess!
      else
        puts "No such file: #{old_path}"
      end
    end
  end

  def self.down
    remove_column :users, :avatar_updated_at
    remove_column :users, :avatar_file_size
    remove_column :users, :avatar_content_type
    remove_column :users, :avatar_filename
  end
end