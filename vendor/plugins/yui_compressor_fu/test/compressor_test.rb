require File.join(File.dirname(__FILE__), '/test_helper.rb')

class CompressorTest < Test::Unit::TestCase
  should "be defined" do
    assert defined?(YuiCompressorFu)
    assert defined?(YuiCompressorFu::Compressor)
  end
  
  should "find bundled jar file" do
    assert File.exists?(YuiCompressorFu::Compressor.path)
  end
  
  should "have configurable path to jar" do
    YuiCompressorFu::Compressor.path = "foobar"
    assert_equal "foobar", YuiCompressorFu::Compressor.path
  end
  
  should "compress sample javascript" do
    expected_js = File.read(File.join(File.dirname(__FILE__), 'samples', 'compressed.js'))
    actual_js = YuiCompressorFu::Compressor.new.compress(File.join(File.dirname(__FILE__), 'samples', 'sample.js'))
    assert_equal expected_js, actual_js
  end
  
  should "compress sample stylesheet" do
    expected_css = File.read(File.join(File.dirname(__FILE__), 'samples', 'compressed.css'))
    actual_css = YuiCompressorFu::Compressor.new.compress(File.join(File.dirname(__FILE__), 'samples', 'sample.css'))
    assert_equal expected_css, actual_css
  end
  
  should "compress into output file" do
    expected_css = File.read(File.join(File.dirname(__FILE__), 'samples', 'compressed.css'))
    actual_css_path = File.join(File.dirname(__FILE__), 'samples', 'actual.css')
    begin
      YuiCompressorFu::Compressor.new.compress(File.join(File.dirname(__FILE__), 'samples', 'sample.css'), actual_css_path)
      assert File.exists?(actual_css_path)
      actual_css = File.read(actual_css_path)
      assert_equal expected_css, actual_css
    ensure
      File.delete(actual_css_path) if File.exists?(actual_css_path)
    end
  end
end