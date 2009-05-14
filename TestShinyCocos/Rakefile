require 'rake/rdoctask'

PROJECT    = "TestShinyCocos.xcodeproj"
TARGET     = "TestShinyCocos"
SDK_DEVICE = "iphoneos2.2.1"
SDK_SIMUL  = "iphonesimulator2.2.1"
XCODEBUILD = "/usr/bin/xcodebuild"

def xcodebuild_str(config = "Debug")
  sdk = ENV['DEVICE'] ? SDK_DEVICE : SDK_SIMUL
  "#{XCODEBUILD} -project #{PROJECT} -target #{TARGET} -sdk #{sdk} -configuration #{config}" 
end

task :default => [:build]

desc "Build ShinyCocos"
task :build do
  sh "#{xcodebuild_str} build"
end

desc "Clean ShinyCocos"
task :clean do
  sh "#{xcodebuild_str} clean"
end

desc "Simulate ShinyCocos App"
task :simulate do
  dir = "#{ENV['HOME']}/Library/Application Support/iPhone Simulator/User/Applications/#{TARGET}"
  mkdir_p dir
  mkdir_p "#{dir}/tmp"
  mkdir_p "#{dir}/Documents"
  mkdir_p "#{dir}/Library"
  cp_r "build/#{ENV['DEVICE'] ? 'Debug-iphoneos' : 'Debug-iphonesimulator'}/#{TARGET}.app", "#{dir}"
  File.open("#{dir}.sb", "w+") do |file|
    file.puts "(version 1)"
    file.puts "(debug deny)"
    file.puts "(allow default)"
  end
end
