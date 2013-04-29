require 'test_helper'

class VideoScreenshoterTest < Test::Unit::TestCase
  context 'make screenshots' do
    setup do
      @input = 'http://techslides.com/demos/sample-videos/small.mp4'
      @output_dir = '/tmp/screenshots_test'
      VideoScreenshoter.new(:input => @input, :output_dir => @output_dir, :times => [1, -2, '50%', '-10%']).make_screenshots
    end
    should 'create screenshots' do
      [1, 2, 3, 5].each do |sec|
        assert File.exists? File.join(@output_dir, "scr00#{sec}.jpg")
        assert File.size(File.join(@output_dir, "scr00#{sec}.jpg")) > 0
      end
    end
  end
end
