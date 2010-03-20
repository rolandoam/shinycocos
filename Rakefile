gem 'rdoc', '>=2.4'
require 'rake/rdoctask'

PROJECT    = "ShinyCocos.xcodeproj"
TARGET     = "ShinyCocos"
SDK_DEVICE = "iphoneos3.1.2"
SDK_SIMUL  = "iphonesimulator3.1.2"
XCODEBUILD = "/usr/bin/xcodebuild"
LIPO       = "/usr/bin/lipo"
SC_VERSION = "0.2.2"

def xcodebuild_str(config = "Debug", sdk = SDK_SIMUL)
  "#{XCODEBUILD} -project #{PROJECT} -target #{TARGET} -sdk #{sdk} -configuration #{config}" 
end

# returns a name for the new lib
def libname(base)
  "#{base}-#{SC_VERSION}.a"
end

task :default => [:build_debug]

desc "Build Debug version of ShinyCocos"
task :build_debug do
  sh "#{xcodebuild_str('Debug', SDK_SIMUL)} build"
  sh "#{xcodebuild_str('Debug', SDK_DEVICE)} build"
end

desc "Build Release version of ShinyCocos"
task :build_release do
  sh "#{xcodebuild_str('Release', SDK_SIMUL)} build"
  sh "#{xcodebuild_str('Release', SDK_DEVICE)} build"
end


desc "Clean ShinyCocos (both debug and release)"
task :build_clean do
  sh "#{xcodebuild_str('Debug')} clean"
  sh "#{xcodebuild_str('Release')} clean"
end

desc "Create static library"
task :distribution => [:build_debug, :build_release] do
  libs = ["build/Release-iphoneos/libShinyCocos.a", "build/Release-iphonesimulator/libShinyCocos.a",
          "build/Debug-iphoneos/libShinyCocos.a", "build/Debug-iphonesimulator/libShinyCocos.a"]
  if File.exists?(libs[0]) && File.exists?(libs[1]) && File.exists?(libs[2]) && File.exists?(libs[3])
    fname_release = libname("libShinyCocos")
    fname_debug = libname("libShinyCocosd")
    sh "#{LIPO} -create #{libs[0]} #{libs[1]} -output build/#{fname_release}"
    sh "#{LIPO} -create #{libs[2]} #{libs[3]} -output build/#{fname_debug}"
    # copy libraries to template
    sh "mkdir -p Template/ShinyCocos/lib"
    sh "rm -f Template/ShinyCocos/lib/*.a"
    sh "cp build/#{fname_release} Template/ShinyCocos/lib/"
    sh "cp build/#{fname_debug} Template/ShinyCocos/lib/"
    # make alias
    sh "cd Template/ShinyCocos/lib && ln -s #{fname_release} libShinyCocos.a"
    sh "cd Template/ShinyCocos/lib && ln -s #{fname_debug} libShinyCocosd.a"
  else
    $stderr.puts "You should build the release and debug targets first!"
  end
end

desc "Install Xcode Template"
task :install_template => [:distribution] do
  sh "sudo rm -rf '/Developer/Platforms/iPhoneOS.platform/Developer/Library/Xcode/Project Templates/Application/ShinyCocos Application'"
  sh "sudo cp -r Template '/Developer/Platforms/iPhoneOS.platform/Developer/Library/Xcode/Project Templates/Application/ShinyCocos Application'"
end

task :revision do
  fname = libname("libShinyCocos")
  puts fname
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_files = %w(
Integration/SC_init.m
Integration/SC_CocosNode.m
Integration/SC_AVAudioPlayer.m
Integration/SC_Action.m
Integration/SC_AtlasSprite.m
Integration/SC_AtlasSpriteManager.m
Integration/SC_BitmatFontAtlas.m
Integration/SC_CocoaAdditions.m
Integration/SC_Director.m
Integration/SC_Label.m
Integration/SC_LabelAtlas.m
Integration/SC_Layer.m
Integration/SC_Menu.m
Integration/SC_Scene.m
Integration/SC_Slider.m
Integration/SC_SolidShapeMap.m
Integration/SC_Sprite.m
Integration/SC_TMXTiledMap.m
Integration/SC_TextField.m
Integration/SC_TextureNode.m
Integration/SC_Transition.m
Integration/SC_Twitter.m
Integration/SC_UserDefaults.m
Integration/ShinyCocos.m
README.rdoc
  )
  rdoc.options += [
    '-E', 'm=c',
    '--main', 'README.rdoc'
  ]
end
