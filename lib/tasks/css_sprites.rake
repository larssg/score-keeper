require 'open3'
require 'digest/sha1'

class CssSprites
  attr_accessor :directory
  attr_accessor :output

  def vertical_offset
    1
  end
  
  def horizontal_offset
    1
  end
  
  def initialize(directory, output)
    self.directory = directory
    self.output = output
  end
  
  def files
    return @files unless @files.nil?
    
    @files = []
    Dir.foreach(self.directory) do |entry|
      extension = File.extname(entry)
      if %w(.jpg .png .gif).include?(extension)
        @files << {
          :key => File.basename(entry, extension),
          :filename => entry,
          :path => File.join(self.directory, entry),
          :dimensions => dimensions(File.join(self.directory, entry))
        }
      end
    end
    @files
  end
  
  def dimensions(path)
    command = 'identify -format "%wx%h" ' + path
    stdin, stdout, stderr = Open3.popen3(command)
    stdout.gets.strip.split('x').collect(&:to_i)
  end
  
  def calculate_size
    width = 2 * horizontal_offset + files.collect { |f| f[:dimensions][0] }.max
    height = vertical_offset * (files.size + 1) + files.collect { |f| f[:dimensions][1] }.sum
    [width, height]
  end
  
  def image_map
    y = vertical_offset
    map = []
    
    files.collect do |file|
      file[:offset] = [horizontal_offset, y]
      y += file[:dimensions][1] + vertical_offset
      file
    end
  end
  
  def generate_css
    rules = []
    image_map.each do |image|
      rules << ".sprite-#{image[:key]} { display: table-cell; display: inline-block; width: #{image[:dimensions][0]}px; height: #{image[:dimensions][1]}px; background: url('#{self.output}') -#{image[:offset][0]}px -#{image[:offset][1]}px no-repeat; }"
    end
    rules.join("\n")
  end
  
  def generate_sprite(filename)
    generate_background(filename)
    composite_images(filename)
  end
  
  def generate_background(filename)
    size = calculate_size
    command = "convert -size #{size[0]}x#{size[1]} xc:transparent #{filename}"
    system(command)
  end
  
  def composite_images(filename)
    image_map.each do |image|
      command = "composite -geometry +#{image[:offset][0]}+#{image[:offset][1]} #{image[:path]} #{filename} #{filename}"
      system(command)
    end
  end
end

namespace :css_sprites do
  desc "Generate css sprite"
  task :generate => :environment do
    generator = CssSprites.new(File.join(Rails.root, 'public', 'images', 'icons'), '/images/{sprites.png}')
    
    sprite_css = generator.generate_css

    sha1 = Digest::SHA1.hexdigest(sprite_css)
    image_filename = "sprites.#{sha1}.cache.png"

    css_filename = File.join(Rails.root, 'public', 'stylesheets', 'sprites.css')
    File.open(css_filename, 'w') { |f| f.write(sprite_css.gsub('{sprites.png}', image_filename)) }
    
    sprite_image = File.join(Rails.root, 'public', 'images', image_filename)
    generator.generate_sprite(sprite_image)
  end
end
