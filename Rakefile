require 'rubygems'
require 'bundler/setup'

Bundler.require :default

require 'rspec/core/rake_task'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet_blacksmith/rake_tasks'

task :default do
  sh %{rake -T}
end

PuppetLint.configuration.send('disable_80chars')


Blacksmith::RakeTask.new do |t|
  t.build = false # do not build the module nor push it to the Forge
  # just do the tagging [:clean, :tag, :bump_commit]
end


desc "Offload release process to Travis."
task :travis_release => [
  :check_changelog,  # check that the changelog contains an entry for the current release
  :"module:release", # do everything except build / push to forge, travis will do that for us
]

desc "Check Changelog."
task :check_changelog do
  v = Blacksmith::Modulefile.new.version
  if File.readlines('CHANGELOG.md').grep(/Release #{v}/).size == 0 then
    fail "Unable to find a CHANGELOG.md entry for the #{v} release."
  end
end
