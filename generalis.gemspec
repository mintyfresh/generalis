# frozen_string_literal: true

require_relative 'lib/generalis/version'

Gem::Specification.new do |spec|
  spec.name          = 'generalis'
  spec.version       = Generalis::VERSION
  spec.authors       = ['Minty Fresh']
  spec.email         = ['7896757+mintyfresh@users.noreply.github.com']

  spec.summary       = 'General Ledger for Ruby of Rails'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/mintyfresh/generalis'
  spec.required_ruby_version = Gem::Requirement.new('>= 3.0')

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata['homepage_uri']          = spec.homepage
  spec.metadata['source_code_uri']       = spec.homepage
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features|integration)/}) }
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord', '>= 5', '< 7'
  spec.add_dependency 'money-rails', '~> 1.15'
end
