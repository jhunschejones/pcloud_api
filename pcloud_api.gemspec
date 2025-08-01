require_relative 'lib/pcloud/version'

Gem::Specification.new do |spec|
  spec.name          = "pcloud_api"
  spec.version       = Pcloud::VERSION
  spec.authors       = ["Joshua Hunsche Jones"]
  spec.email         = ["joshua@hunschejones.com"]

  spec.summary       = "A Ruby library for interacting with the pCloud API"
  spec.homepage      = "https://github.com/jhunschejones/pcloud_api"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/jhunschejones/pcloud_api"
  spec.metadata["changelog_uri"] = "https://github.com/jhunschejones/pcloud_api/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|.github)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", ">= 1.17", "< 3.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry", "~> 0.13"

  spec.add_dependency "httparty", ">= 0.16", "< 1.0"
  spec.add_dependency "tzinfo"
end
