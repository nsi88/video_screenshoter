require "video_screenshoter/version"
require "video_screenshoter/video"

module VideoScreenshoter
  class << self
    attr_accessor :ffmpeg, :output_dir, :output_file, :verbose
  end
  self.ffmpeg = '/usr/local/bin/ffmpeg'
  self.output_dir = '/tmp/screenshots'
  self.output_file = 'scr%03d.jpg'
  self.verbose = false

  def self.new params
    VideoScreenshoter::Video.new params
  end
end
