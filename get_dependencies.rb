#!/usr/bin/env ruby

require 'fileutils'
include FileUtils

RUBY_1_9_1      = "http://svn.ruby-lang.org/repos/ruby/branches/ruby_1_9_1"
COCOS_2D_IPHONE = "http://cocos2d-iphone.googlecode.com/svn/branches/branch-0.7"
SVN = `which svn`.strip

def do_shell(msg)
  print msg + " "
  $stdout.flush
  yield if block_given?
  puts "done!"
end

if !SVN || !File.exists?(SVN)
  puts "Subversion not installed!"
  exit(1)
end

# checking out ruby 1.9
do_shell "checking out ruby 1.9..." do
  if File.exists?("ruby")
    # ok, the directory exists, check if it's a subversion checkout, if so, update
    # else... keep it that way
    if File.exists?("ruby/.svn")
      system("cd ruby; svn up > /dev/null")
    end
  else
    system("svn co '#{RUBY_1_9_1}' ruby > /dev/null")
  end
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
  ruby_dir = "ruby"
  if File.exists?(ruby_dir) and File.directory?(ruby_dir)
    if !File.exists?("#{ruby_dir}/configure")
      system("cd #{ruby_dir}; sh autoconf")
      system("cd #{ruby_dir}; ./configure > /dev/null")
    end
    system("cd #{ruby_dir}; make clean > /dev/null")
    # copy the header we need to compile in the device
    cp "/usr/include/crt_externs.h", "ruby/crt_externs.h"
  end
end

do_shell "making ruby 1.9.1 (we need some auto-generated files)..." do
  ruby_dir = "ruby"
  system("cd #{ruby_dir}; make > /dev/null")
  # copy ruby config.h to where it should be
  cp ".ext/include/i386-darwin9.6.0/ruby/config.h", "ruby/include/ruby/config.h"
  cp "/usr/include/crt_externs.h", "ruby/include/crt_externs.h"
end

