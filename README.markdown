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

* subversion (to fetch current branch-0.7 of cocos2d-iphone)
* curl (installed with MacOS X, to fetch ruby)

## Installation/Building

First, run the script that will fetch ruby and cocos2d-iphone:

    ./get_dependencies.rb

or:

    ruby get_dependencies.rb

Open the cocos2d-iphone project and set the output directory to
"../build" instead of "build".

Open the TestShinyCocos project and build.

Now you're ready to rock :-)

## Documentation

Use rdoc:

    rdoc -E m=c Integration --main Cocos2D
    open doc/index.html

You might need a newer version of rdoc:

    sudo gem install rdoc

The one that comes with Leopard is too old and complains about the
enclosing module not being found.

## Adding extensions from the stdlib

If you need to add an extension from the stdlib (or your own extension)
add the source file to the "ext" group in the ShinyCocos project file.
It will be statically linked to ruby. You should also add the Init call
in the function <tt>Init_SC_Ruby_Extensions</tt>, in the
<tt>SC_init.m</tt> file.

After that, make sure you add an empty file named after your extension,
i.e: stringio.rb for the StringIO extension, inside the "lib" directory
of your project. That way, your code can still call
<tt>require 'stringio'</tt>.

I will try to find an easier way :-).

For ruby-only extensions, just add them to the lib directory.

## TODO

* Add documentation :-)
* Integrate the rest of the cocos2d-iphone API
* Check for leaks
* Benchmarks
