# encoding: utf-8

module VideoScreenshoter
  class Video < Abstract

    def initialize params
      super
    end

    def run
      times.each { |time| ffmpeg_run(time) and imagemagick_run(output_fullpath(time)) }
    end

    alias :make_screenshots :run
    alias :make_thumbnails :run

    private

    def input_duration
      if matches = `#{ffmpeg} -i #{input} 2>&1`.match(/Duration:\s*(\d{2}):(\d{2}):(\d{2}\.\d{2})/)
        matches[1].to_i * 3600 + matches[2].to_i * 60 + matches[3].to_f
      end
    end
  end
end
