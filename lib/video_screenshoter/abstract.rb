# encoding: utf-8

module VideoScreenshoter
  class Abstract
    attr_accessor :ffmpeg, :imagemagick, :output_dir, :output_file, :input, :exact, :times, :offset_start, :offset_end, :duration, :verbose, :size, :presets

    def initialize params
      params.each_with_index do |param, index|
        params[index] = Shellwords.escape(param) if param.is_a?(String)
      end
      [:ffmpeg, :imagemagick, :output_dir, :output_file, :verbose].each do |attr|
        self.send("#{attr}=".to_sym, params[attr].nil? ? VideoScreenshoter.send(attr) : params[attr])
      end
      FileUtils.mkdir_p self.output_dir
      self.input = params[:input]
      self.duration = input_duration
      raise ArgumentError.new('Incorrect or empty m3u8 playlist') if duration.nil? || duration <= 0

      # if false ffmpeg uses fast seek by keyframes like: ffmpeg -ss ... -i
      self.exact = params[:exact]

      if params[:times]
        self.exact = true if exact.nil?
        self.times = params[:times].to_a.map do |time|
          if time.is_a?(String) && matches = time.match(/(.*)%$/)
            time = matches[1].to_f / 100 * duration
          end
          time = duration + time if time < 0
          time = time.to_i
          time
        end.uniq
      elsif (number = params[:number].to_i) > 0
        [:offset_start, :offset_end].each do |attr|
          if percent = params[attr].to_s.match(/^(\d+)\\?%$/).to_a[1]
            self.send("#{attr}=", duration * percent.to_i / 100.0)
          else
            self.send("#{attr}=", params[attr].to_f)
          end
        end
        self.times = number.times.to_a.map { |time| ((offset_start + (duration - offset_start - offset_end) / number * time) * 100).round / 100.0 }.uniq
      else
        raise ArgumentError.new('times or number required') if times.empty?
      end

      self.size = params[:size] ? "-s #{params[:size]}" : ''

      # TODO possibility to replace original image by presetted image
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
      is = exact ? "-i #{input} -ss #{time}" : "-ss #{time} -i #{input}"
      "#{ffmpeg} #{is} -acodec -an #{size} -f image2 -vframes 1 -y #{output} 1>/dev/null 2>&1"
    end

    def ffmpeg_run time = nil
      cmd = ffmpeg_command(input, output_fullpath(time), time)
      puts cmd if verbose
      system cmd
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
          system cmd
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
