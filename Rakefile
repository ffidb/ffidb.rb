# This is free and unencumbered software released into the public domain.

require_relative 'lib/ffidb'

require 'rake'

task default: %w(install)

VERSION = File.read('VERSION').chomp

task :build => %w(ffidb.gemspec VERSION) do |t|
  sh "gem build #{t.prerequisites.first}"
end

file "ffidb-#{VERSION}.gem" => %w(build)

task :install => %W(ffidb-#{VERSION}.gem VERSION) do |t|
  sh "gem install #{t.prerequisites.first}"
end
