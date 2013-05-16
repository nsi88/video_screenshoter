require 'test_helper'

class VideoScreenshoterTest < Test::Unit::TestCase
  context 'video' do
    setup do
      @input = 'http://techslides.com/demos/sample-videos/small.mp4'
      @output_dir = '/tmp/video_screenshots_test'
      VideoScreenshoter.new(:input => @input, :output_dir => @output_dir, :times => [1, -2, '50%', '-10%']).make_screenshots
    end
    should 'create screenshots' do
      [1, 2, 3, 5].each do |sec|
        assert File.exists? File.join(@output_dir, "scr00#{sec}.jpg")
        assert File.size(File.join(@output_dir, "scr00#{sec}.jpg")) > 0
      end
    end
  end

  context 'hls' do
    context 'with 1 level playlist' do
      setup do
        @input = 'http://devimages.apple.com.edgekey.net/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8'
        @output_dir = '/tmp/hls_screenshots_test'
      end
      should 'raise error' do
        assert_raises(ArgumentError) { VideoScreenshoter.new(:input => @input, :output_dir => @output_dir, :times => ['10%', '50%']).make_thumbnails }
      end
    end

    context 'with 2 level playlist' do
      setup do
        @input = 'http://devimages.apple.com.edgekey.net/streaming/examples/bipbop_4x3/gear4/prog_index.m3u8'
        @output_dir = '/tmp/hls_screenshots_test'
        VideoScreenshoter.new(:input => @input, :output_dir => @output_dir, :times => ['10%', '50%', '-10%']).make_thumbnails
      end
      should 'create screenshots' do
        ["scr1620.jpg", "scr180.jpg", "scr900.jpg"].each do |scr|
          assert File.exists?(File.join(@output_dir, scr))
          assert File.size(File.join(@output_dir, scr)) > 0
        end
      end
    end
  end
end
