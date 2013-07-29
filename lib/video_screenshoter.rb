require "video_screenshoter/version"
require "fileutils"
require "video_screenshoter/abstract"
require "video_screenshoter/video"
require "video_screenshoter/hls"
require "video_screenshoter/image"
require "shellwords"

module VideoScreenshoter
  class << self
    attr_accessor :ffmpeg, :imagemagick, :output_dir, :output_file, :verbose
  end
  self.ffmpeg = '/usr/local/bin/ffmpeg'
  self.output_dir = '/tmp/screenshots'
  self.output_file = 'scr%03d.jpg'
  self.verbose = false
  self.imagemagick = '/usr/bin/convert'

  def self.new params
    raise ArgumentError.new('Input is needed') unless params[:input]
    raise ArgumentError.new('Incorrect type param') unless [nil, 'hls', 'video', 'image'].include? params[:type]
    if params[:type] == 'hls' || File.extname(params[:input]).downcase == '.m3u8'
      VideoScreenshoter::Hls.new(params)
    elsif params[:type] == 'image' || ['.gif','.png','.jpg','.jpeg', '.png'].include?(File.extname(params[:input]).downcase)
      VideoScreenshoter::Image.new(params)
    else
      VideoScreenshoter::Video.new(params)
    end
  end
end
