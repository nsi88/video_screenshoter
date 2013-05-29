require "video_screenshoter/version"
require "fileutils"
require "video_screenshoter/abstract"
require "video_screenshoter/video"
require "video_screenshoter/hls"

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
    raise ArgumentError.new('Incorrect type param') unless [nil, 'hls', 'video'].include? params[:type]
    params[:type] ||= File.extname(params[:input]) == '.m3u8' ? 'hls' : 'video'
    params[:type] == 'hls' ? VideoScreenshoter::Hls.new(params) : VideoScreenshoter::Video.new(params)
  end
end
