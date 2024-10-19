# frozen_string_literal: true

require_relative "lib/valkey/objects/version"

Gem::Specification.new do |spec|
  spec.name = "valkey-objects"
  spec.version = Valkey::Objects::VERSION
  spec.authors = ["Erik Olson"]
  spec.email = ["xorgnak@gmail.com"]

  spec.summary = "A ruby valkey client inspired by the redis-objects gem."
  spec.description = spec.summary
  spec.homepage = "https://github.com/xorgnak/valkey-client"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "redis-client"
  spec.add_dependency "awesome_print"
  spec.add_dependency "json"
  spec.add_dependency "ruby-duration"
  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
