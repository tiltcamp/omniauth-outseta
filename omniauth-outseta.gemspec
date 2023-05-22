# frozen_string_literal: true

require_relative "lib/omniauth/outseta/version"

Gem::Specification.new do |spec|
  spec.name = "omniauth-outseta"
  spec.version = Omniauth::Outseta::VERSION
  spec.authors = ["TiltCamp"]
  spec.email = ["hello@tiltcamp.com"]

  spec.summary = "(WIP) Use Outseta with OmniAuth."
  spec.description = "(WIP) Use Outseta as a provider strategy for OmniAuth and Devise."
  spec.homepage = "https://github.com/tiltcamp/omniauth-outseta"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.6"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata = {
    "bug_tracker_uri" => "#{spec.homepage}/issues",
    "changelog_uri" => "#{spec.homepage}/blob/main/CHANGELOG.md",
    "documentation_uri" => spec.homepage.to_s,
    "homepage_uri" => spec.homepage.to_s,
    "source_code_uri" => spec.homepage.to_s
  }

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "jwt", "~> 2.7"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
