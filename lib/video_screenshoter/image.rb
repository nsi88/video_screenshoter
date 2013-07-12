# encoding: utf-8

module VideoScreenshoter
  class Image < Abstract

    def initialize params
      [:ffmpeg, :imagemagick, :output_dir, :output_file, :verbose].each do |attr|
        self.send("#{attr}=".to_sym, params[attr].nil? ? VideoScreenshoter.send(attr) : params[attr])
      end
      FileUtils.mkdir_p self.output_dir
      self.input = params[:input]
      if params[:presets] && params[:presets].is_a?(Hash)
        self.presets = {}
        params[:presets].each do |name, preset|
          self.presets[name.to_sym] = !preset || preset.empty? || preset.index('-') == 0 ? preset : "-resize #{preset}"
        end
      end
      raise ArgumentError.new('Presets are needed') if presets.nil? || presets.empty?
    end

    def run
      imagemagick_run input
      Hash[*presets.keys.map { |p| [p, output_with_preset(input, p)] }.flatten]
    end

    alias :make_screenshots :run
    alias :make_thumbnails :run
  end
end
