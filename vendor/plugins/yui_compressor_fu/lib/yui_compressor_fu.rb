module YuiCompressorFu
  YUI_COMPRESSOR_VERSION = '2.4.2'
end

require File.join(File.dirname(__FILE__), "yui_compressor_fu", "compressor.rb")
require File.join(File.dirname(__FILE__), "yui_compressor_fu", "asset_tag_helper_ext.rb")

ActionView::Helpers::AssetTagHelper.send(:include, YuiCompressorFu::AssetTagHelperExt)