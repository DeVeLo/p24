# frozen_string_literal: true

require_relative 'lib/p24/version'

Gem::Specification.new do |spec|
  spec.name = 'p24'
  spec.version = P24::VERSION
  spec.authors = ['Konrad Makowski']
  spec.email = ['konrad@snopkow.eu']

  spec.summary = 'Przelewy24 adapter'
  spec.homepage = 'https://github/DeVeLo/p24'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.3.1'

  spec.metadata['allowed_push_host'] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata['homepage_uri'] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .gitlab-ci.yml appveyor Gemfile])
    end
  end
  spec.bindir = 'bin'
  spec.executables = spec.files.grep(%r{\Abin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'httparty'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
