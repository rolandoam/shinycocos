#!/usr/bin/env ruby

require 'fileutils'
include FileUtils

RUBY_1_9_1      = "ftp://ftp.ruby-lang.org/pub/ruby/stable-snapshot.tar.gz"
COCOS_2D_IPHONE = "http://cocos2d-iphone.googlecode.com/svn/branches/branch-0.7"

def do_shell(msg)
  print msg + " "
  $stdout.flush
  yield if block_given?
  puts "done!"
end

# get ruby 1.9
do_shell "downloading ruby 1.9..." do
  ruby_tar = RUBY_1_9_1.split('/').last
  rm ruby_tar if File.exists?(ruby_tar)
  system("curl -sLO '#{RUBY_1_9_1}' > /dev/null")
end

# checking out cocos-2d
do_shell "checking out cocos-2d..." do
  if File.exists?("cocos2d-iphone")
    # ok, the directory exists, check if it's a subversion checkout, if so, update
    # else... keep it that way
    if File.exists?("cocos2d-iphone/.svn")
      system("cd cocos2d-iphone; svn up > /dev/null")
    end
  else
    system("svn co '#{COCOS_2D_IPHONE}' cocos2d-iphone > /dev/null")
  end
end

# configure ruby 1.9
do_shell "configuring ruby 1.9..." do
  ruby_tar = RUBY_1_9_1.split('/').last
  ruby_dir = File.basename(ruby_tar, ".tar.gz")
  system("tar xzf #{ruby_tar}")
  system("cd ruby; ./configure > /dev/null")
  # copy the header we need to compile in the device
  cp "/usr/include/crt_externs.h", "ruby/crt_externs.h"
  rm ruby_tar
end

do_shell "making ruby 1.9 (we need some auto-generated files)..." do
  system("cd ruby; make > /dev/null")
end
