require 'test_helper'

class VideoScreenshoterTest < Test::Unit::TestCase
  context 'video' do
    setup do
      @input = 'http://techslides.com/demos/sample-videos/small.mp4'
      @output_dir = '/tmp/video_screenshots_test'
      `rm -r #{@output_dir}` if File.exists?(@output_dir)
    end
    
    context '' do
      setup do
        VideoScreenshoter.new(:input => @input, :output_dir => @output_dir, :times => [1, -2, '50%', '-10%']).make_screenshots
      end
      
      should 'create screenshots' do
        [1, 2, 3, 5].each do |sec|
          assert File.exists? File.join(@output_dir, "scr00#{sec}.jpg")
          assert File.size(File.join(@output_dir, "scr00#{sec}.jpg")) > 0
        end
      end
    end

    context 'with presets' do
      setup do
        VideoScreenshoter.new(:input => @input, :output_dir => @output_dir, :times => [1, -1], :presets => {:big => '1024x768', :small => '-resize 400x100^ -gravity center -crop 400x100+0+0'}, :imagemagick => '/usr/bin/convert').make_screenshots
      end
      should 'create screenshots' do
        [1,4].each do |sec|
          assert File.exists? File.join(@output_dir, "scr00#{sec}.jpg")
          assert File.exists? File.join(@output_dir, "scr00#{sec}_big.jpg")
          assert File.exists? File.join(@output_dir, "scr00#{sec}_small.jpg")
        end
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
        `rm -r  #{@output_dir}` if File.exists? @output_dir
      end
      
      context '' do
        setup do
          VideoScreenshoter.new(:input => @input, :output_dir => @output_dir, :times => ['10%', '50%', '-10%']).make_thumbnails
        end
        should 'create screenshots' do
          ["scr1620.jpg", "scr180.jpg", "scr900.jpg"].each do |scr|
            assert File.exists?(File.join(@output_dir, scr))
            assert File.size(File.join(@output_dir, scr)) > 0
          end
        end
      end

      context 'with presets' do
        setup do
          VideoScreenshoter.imagemagick = '/usr/bin/convert'
          VideoScreenshoter.new(:input => @input, :output_dir => @output_dir, :times => ['10%', '50%', '-10%'], :presets => {:big => '1024x768', :small => '140x100!'}).make_thumbnails
        end
        should 'create screenshots' do
          ["scr1620.jpg", "scr180.jpg", "scr900.jpg"].each do |scr|
            assert File.exists?(File.join(@output_dir, scr))
            assert File.exists?(File.join(@output_dir, scr.sub('.jpg', '_big.jpg')))
            assert File.exists?(File.join(@output_dir, scr.sub('.jpg', '_small.jpg')))
          end
          assert `/usr/local/bin/ffmpeg -i #{File.join(@output_dir, "scr900_small.jpg")} 2>&1`.include?('140x100')
        end
      end
    end
  end

  context 'image' do
    setup do
      @input = 'test/fixtures/test.jpg'
      @output_dir = '/tmp/image_screenshots_test'
      @presets = {:big=>"1280x720", :small=>"144x81", :big43=>"-resize 1280x960^ -gravity center -crop 1280x960+0+0", :small43=>"-resize 144x108^ -gravity center -crop 144x108+0+0"}
      `rm -r #{@output_dir}` if File.exists? @output_dir
      @res = VideoScreenshoter.new(:input => @input, :output_dir => @output_dir, :presets => @presets, :type => 'image').run
    end
    should 'create screenshots' do
      assert_equal @presets.count, @res.count
      @res.each do |res|
        assert File.exists?(res)
        assert File.size(res) > 0
      end
      assert File.size(@res.first) != File.size(@res.last)
    end
  end
end
