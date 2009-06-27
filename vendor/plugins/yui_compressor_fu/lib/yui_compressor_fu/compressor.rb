module YuiCompressorFu
  class Compressor
    class << self
      attr_writer :path
      
      def path
        @path ||= File.join(File.dirname(__FILE__), '..', '..', 'vendor', "yuicompressor-#{YUI_COMPRESSOR_VERSION}.jar")
      end
    end
    
    def compress(input_path, output_path = nil)
      cmd = "java -jar #{self.class.path} #{input_path}"
      
      if output_path
        cmd << " -o #{output_path}"
        system(cmd)
      else
        `#{cmd}`
      end
    end
  end
end