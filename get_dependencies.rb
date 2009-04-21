#!/usr/bin/env ruby

require 'fileutils'
include FileUtils

RUBY_1_9_1      = "ftp://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.1-p0.tar.gz"
COCOS_2D_IPHONE = "http://cocos2d-iphone.googlecode.com/svn/branches/branch-0.7"

def do_shell(msg)
  print msg + " "
  $stdout.flush
  yield
  puts "done!"
end

# get ruby 1.9
do_shell "downloading ruby 1.9..." do
  system("curl -sLO '#{RUBY_1_9_1}' > /dev/null")
end

# checking out cocos-2d
do_shell "checking out cocos-2d..." do
  system("svn co '#{COCOS_2D_IPHONE}' cocos2d-iphone")
end

# configure ruby 1.9
do_shell "configuring ruby 1.9..." do
  ruby_tar = RUBY_1_9_1.split('/').last
  ruby_dir = File.basename(ruby_tar, ".tar.gz")
  system("tar xzf #{ruby_tar}")
  mv ruby_dir, "ruby"
  system("cd ruby; ./configure > /dev/null")
  config_h = Dir["ruby/.ext/**/config.h"].first
  if config_h && File.exists?(config_h)
    mkdir_p "ruby/iphone/ruby"
    cp config_h, "ruby/iphone/ruby/config.h"
  end
  cp "/usr/include/crt_externs.h", "ruby/iphone/crt_externs.h"
  rm ruby_tar
end
