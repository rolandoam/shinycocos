require 'rake/rdoctask'

PROJECT    = "ShinyCocos.xcodeproj"
TARGET     = "ShinyCocos"
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

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_files = %w(
Integration/SC_init.m
Integration/SC_AtlasSprite.m
Integration/SC_AtlasSpriteManager.m
Integration/SC_CocoaAdditions.m
Integration/SC_CocosNode.m
Integration/SC_Director.m
Integration/SC_Layer.m
Integration/SC_Menu.m
Integration/SC_MenuItemAtlasSprite.m
Integration/SC_Scene.m
Integration/SC_SolidShapeMap.m
Integration/SC_Sprite.m
Integration/SC_Texture2D.m
Integration/SC_TextureNode.m
Integration/SC_TiledMap.m
Integration/SC_Twitter.m
Integration/SC_UserDefaults.m
Integration/SC_ids.m
Integration/ShinyCocos.m
README.rdoc
  )
  rdoc.options += [
    '-E', 'm=c',
    '--main', 'README.rdoc'
  ]
end
