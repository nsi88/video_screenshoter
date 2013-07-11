# encoding: utf-8

module VideoScreenshoter
  class Abstract
    attr_accessor :ffmpeg, :imagemagick, :output_dir, :output_file, :input, :times, :duration, :verbose, :size, :presets

    def initialize params
      [:ffmpeg, :imagemagick, :output_dir, :output_file, :verbose].each do |attr|
        self.send("#{attr}=".to_sym, params[attr].nil? ? VideoScreenshoter.send(attr) : params[attr])
      end
      FileUtils.mkdir_p self.output_dir
      self.input = params[:input]
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
      if params[:presets] && params[:presets].is_a?(Hash)
        self.presets = {}
        params[:presets].each do |name, preset|
          self.presets[name.to_sym] = !preset || preset.empty? || preset.index('-') == 0 ? preset : "-resize #{preset}"
        end
      end
    end

    def output_fullpath time, preset = nil
      res = sprintf(File.join(output_dir, output_file), time)
      res.sub!(File.extname(res), "_#{preset}#{File.extname(res)}") if preset
      res
    end

    def ffmpeg_command input, output, time
      "#{ffmpeg} -i #{input} -acodec -an -ss #{time} #{size} -f image2 -vframes 1 -y #{output} 2>/dev/null 1>&2"
    end

    def output_with_preset input, preset_name
      File.join(output_dir, File.basename(input, File.extname(input)) + '_' + preset_name.to_s + File.extname(input))
    end

    def imagemagick_command input, preset_name
      preset = presets[preset_name.to_sym]
      if !preset || preset.empty?
        "cp #{input} #{output_with_preset(input, preset_name)}"
      else
        "#{imagemagick} #{input} #{preset} #{output_with_preset(input, preset_name)}"
      end
    end

    def imagemagick_run scr
      if presets
        presets.each do |preset_name, preset|
          cmd = imagemagick_command(scr, preset_name)
          puts cmd if verbose
          `#{cmd}`
        end
      end
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
