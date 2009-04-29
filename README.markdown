# ShinyCocos

## About

ShinyCocos is a ruby bindings for the Cocos2D-iphone game framework.

The idea is to have a very rubyish binding for the awesome
[cocos2d-iphone](http://code.google.com/p/cocos2d-iphone) game
framework. It also includes the Chipmunk ruby bindings.

## Why?

Why not?

It makes things easier and faster to prototype, it's not a big overhead
and also, ruby takes care of your GC.

## How?

Bundled with your application there is a ruby interpreter (ruby 1.9.1,
stable-snapshot). The interpreter is loaded with a simple call from
within your App Delegate. The interpreter then loads "main.rb". From
there, you can have as many classes/files as you want.

For each cocos2d class there is (or will be) a Ruby version of the
class, right now, the following classes are implemented:

* Texture2D
* Director
* CocosNode
* Scene
* TextureNode
* Sprite
* AtlasSprite
* AtlasSpriteManager
* AtlasAnimation

The idea is to support every class provided by cocos2d-iphone. Please
note that this is a project still starting, so most of the classes are
not implemented 100%.

## Requirements

There are only install requirements:

* svn (to fetch current branch-0.7 of cocos2d-iphone)
* curl (installed with MacOS X, to fetch ruby)

## Installation/Building

First, run the script that will fetch ruby and cocos2d-iphone:

    > ./get_dependencies.rb

or:

    > ruby get_dependencies.rb

Open the cocos2d-iphone project and set the output directory to
"../build" instead of "build".

Open the TestShinyCocos project and build.

Now you're ready to rock :-)

## Documentation

Use rdoc:

    rdoc -E m=c Integration/*
    open doc/index.html

## TODO

* Add documentation :-)
* Integrate the rest of the cocos2d-iphone API
* Benchmarks
