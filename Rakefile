# This is free and unencumbered software released into the public domain.

PROJECT = Dir['*.gemspec'].first.sub('.gemspec', '')
VERSION = File.read('VERSION').chomp

require_relative "lib/#{PROJECT}"

require 'rake'

task default: %w(install)

file "#{PROJECT}-#{VERSION}.gem" => %w(build)

desc "Build #{PROJECT}-#{VERSION}.gem from #{PROJECT}.gemspec"
task :build => %W(#{PROJECT}.gemspec VERSION) do |t|
  sh "gem build #{t.prerequisites.first}"
end

desc "Install #{PROJECT}-#{VERSION}.gem locally"
task :install => %W(#{PROJECT}-#{VERSION}.gem VERSION) do |t|
  sh "gem install #{t.prerequisites.first}"
end
