module YuiCompressorFu
  module AssetTagHelperExt
    def self.included(base)
      base.alias_method_chain :write_asset_file_contents, :yui_compression
    end
    
    def write_asset_file_contents_with_yui_compression(*args, &blk)
      joined_asset_path, short_asset_paths = args
      
      # Short versions of paths are necessary to pass along to Rails
      short_minified_paths = short_asset_paths.collect do |p|
        ext = File.extname(p)
        p.sub(ext, "-min#{ext}")
      end
      
      
      full_asset_paths = short_asset_paths.map {|p| asset_file_path(p)}
      full_minified_paths = short_minified_paths.map {|p| asset_file_path(p)}
      
      compressor = YuiCompressorFu::Compressor.new
      
      begin
        full_asset_paths.each_with_index{|p, i| compressor.compress(p, full_minified_paths[i])}
        args[1] = short_minified_paths
        write_asset_file_contents_without_yui_compression(*args, &blk)
      ensure
        full_minified_paths.each{|p| File.delete(p) if File.exists?(p)}
      end
    end
  end
end