require "open-uri"
require "tempfile"
require "stringio"
require "fileutils"

module MiniMagick
  class MiniMagickError < Exception; end
  
  VERSION = '1.2.0'
    
  class Image
    attr :path

    # Class Methods
    # -------------
    class <<self
      def from_blob(blob)      
        begin
          tmp = Tempfile.new("minimagic")
          tmp.binmode 
          tmp.write(blob)
        ensure
          tmp.close
        end      
        return self.new(tmp.path)
      end
      
      # Use this if you don't want to overwrite the image file
      def from_file(image_path)      
        File.open(image_path, "rb") do |f|
          self.from_blob(f.read)
        end
      end
    end
    
    # Instance Methods
    # ----------------    
    def initialize(input_path)      
      @path = input_path
      
      # Ensure that the file is an image
      run_command("identify #{@path}")      
    end
    
    def [](value)
      # Why do I go to the trouble of putting in newline chars? Because otherwise animated gifs screw everything up
      case value.to_s
      when "format"
        run_command("identify", "-format", format_option("%m"), @path).split("\n")[0]        	
      when "height"
        run_command("identify", "-format", format_option("%h"), @path).split("\n")[0].to_i
      when "width"
        run_command("identify", "-format", format_option("%w"), @path).split("\n")[0].to_i
      when "original_at"
        # Get the EXIF original capture as a Time object
        Time.local(*self["EXIF:DateTimeOriginal"].split(/:|\s+/)) rescue nil
      when /^EXIF\:/i
        run_command('identify', '-format', "\"%[#{value}]\"", @path).chop              
      else
        run_command('identify', '-format', "\"#{value}\"", @path)
      end
    end
    
    # This is a 'special' command because it needs to change @path to reflect the new extension
    def format(format)
      run_command("mogrify", "-format", format, @path)
      @path = @path.sub(/\.\w+$/, ".#{format}")
      
      raise "Unable to format to #{format}" unless File.exists?(@path)
    end
    
    # Writes the temporary image that we are using for processing to the output path
    def write(output_path)        
      FileUtils.copy_file @path, output_path
      run_command "identify #{output_path}"		# Verify that we have a good image
    end
      
    # If an unknown method is called then it is sent through the morgrify program
    # Look here to find all the commands (http://www.imagemagick.org/script/mogrify.php)
    def method_missing(symbol, *args)
      args.push(@path) # push the path onto the end
      run_command("mogrify", "-#{symbol}", *args)
    end
    
    # You can use multiple commands together using this method
    def combine_options(&block)      
      c = CommandBuilder.new
      block.call c
      run_command("mogrify", *c.args << @path)
    end
          
    # Private (Don't look in here!)
    # -----------------------------
    private
    
    # Check to see if we are running on win32 -- we need to escape things differently    
    def windows?
    	!(RUBY_PLATFORM =~ /win32/).nil?
    end    
       
    # Outputs a carriage-return delimited format string for Unix and Windows 
    def format_option(format)
        if windows?
        	format = "#{format}\\n"
        else
        	format = "#{format}\\\\n"
        end              
    end    
        
    def run_command(command, *args)
      args = args.collect do |a|
        a = a.to_s
        unless a[0,1] == '-'  # don't quote switches
          "\"#{a}\""          # values quoted because they can contain characters like '>'
        else
          a
        end
      end
      
      output = `#{command} #{args.join(' ')}`
      
      if $? != 0
        raise MiniMagickError, "ImageMagick command (#{command} #{args.join(' ')}) failed: Error Given #{$?}"
      else
        return output
      end  
    end
  end

  class CommandBuilder
    attr :args
    
    def initialize
      @args = []
    end
    
    def method_missing(symbol, *args)
      @args += ["-#{symbol}"] + args
    end    
  end
end
