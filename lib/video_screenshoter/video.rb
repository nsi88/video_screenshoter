# encoding: utf-8

module VideoScreenshoter
  class Video
    attr_accessor :ffmpeg, :output_dir, :output_file, :input, :times, :duration, :verbose

    def initialize params
      [:ffmpeg, :output_dir, :output_file, :verbose].each do |attr|
        self.send("#{attr}=".to_sym, params[:attr].nil? ? VideoScreenshoter.send(attr) : params[:attr])
      end
      self.input = params[:input] or raise ArgumentError.new('Input is needed')
      self.duration = input_duration or raise ArgumentError.new('Incorrect video file')
      self.times = params[:times].to_a.map do |time|
        if time.is_a?(String) && matches = time.match(/(.*)%$/)
          time = matches[1].to_f / 100 * duration
        end
        time = duration + time if time < 0
        time
      end
    end

    def make_screenshots
      times.each do |time|
        cmd = "#{ffmpeg} -i #{input} -acodec -an -ss #{time} -f image2 -vframes 1 -y #{sprintf(File.join(output_dir, output_file), time)} 2>/dev/null 1>&2"
        puts cmd if verbose
        `#{cmd}`
      end
    end

    private

    def input_duration
      if matches = `#{ffmpeg} -i #{input} 2>&1`.match(/Duration:\s*(\d{2}):(\d{2}):(\d{2}\.\d{2})/)
        matches[1].to_i * 3600 + matches[2].to_i * 60 + matches[3].to_f
      end
    end
  end
end
