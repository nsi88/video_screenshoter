# encoding: utf-8

module VideoScreenshoter
  class Abstract
    attr_accessor :ffmpeg, :output_dir, :output_file, :input, :times, :duration, :verbose, :size

    def initialize params
      [:ffmpeg, :output_dir, :output_file, :verbose].each do |attr|
        self.send("#{attr}=".to_sym, params[attr].nil? ? VideoScreenshoter.send(attr) : params[attr])
      end
      FileUtils.mkdir_p self.output_dir
      self.input = params[:input] or raise ArgumentError.new('Input is needed')
      self.duration = input_duration
      raise ArgumentError.new('Incorrect or empty m3u8 playlist') if duration.to_i == 0
      self.times = params[:times].to_a.map do |time|
        if time.is_a?(String) && matches = time.match(/(.*)%$/)
          time = matches[1].to_f / 100 * duration
        end
        time = duration + time if time < 0
        time = time.to_i
        time
      end.uniq
      self.size = params[:size] ? "-s #{params[:size]}" : ''
    end

    def output_fullpath time
      sprintf(File.join(output_dir, output_file), time)
    end

    def command input, output, time
      "#{ffmpeg} -i #{input} -acodec -an -ss #{time} #{size} -f image2 -vframes 1 -y #{output} 2>/dev/null 1>&2"
    end

    def run
      raise NotImplementedError
    end

    protected

    def input_duration
      raise NotImplementedError
    end
  end
end
