# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'video_screenshoter/version'

Gem::Specification.new do |spec|
  spec.name          = "video_screenshoter"
  spec.version       = VideoScreenshoter::VERSION
  spec.authors       = ["novikov"]
  spec.email         = ["novikov@inventos.ru"]
  spec.description   = %q{Documentation coming soon...}
  spec.summary       = %q{Make screenshots from video or m3u8 files using ffmpeg}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "test-unit"
  spec.add_development_dependency "shoulda-context"

  spec.requirements << 'ffmpeg'
end
