# frozen_string_literal: true
namespace :pngs do
  desc "Optimize PNGs"
  task :optimize => :environment do
    image_path = File.join(Rails.root, 'public', 'images')
    Dir.foreach(image_path) do |entry|
      next unless File.extname(entry) == '.png'
      command = "optipng -o 7 #{File.join(image_path, entry)}"
      system(command)
    end
  end
end