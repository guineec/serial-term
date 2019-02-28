
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "sterm/version"

Gem::Specification.new do |spec|
  spec.name          = "sterm"
  spec.version       = Sterm::VERSION
  spec.executables << 'sterm'
  spec.authors       = ["Cian Guinee"]
  spec.email         = ["cian.guinee@gmail.com"]
  spec.licenses      = ["GPL-2.0"] # As required by the serialport dependency
  spec.summary       = %q{Shows data transmitted from a serial device}
  spec.homepage      = "https://github.com/guineec/serial-term"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_dependency "serialport", "~> 1.3.1"
  spec.add_dependency "rainbow", "~> 3.0.0"
end
