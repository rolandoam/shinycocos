#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface MenuItemAtlasSprite : MenuItem
{
	BOOL selected;
	AtlasSprite *normalImage, *selectedImage, *disabledImage;
}

/// Sprite (image) that is displayed when the MenuItem is not selected
@property (readonly) AtlasSprite *normalImage;
/// Sprite (image) that is displayed when the MenuItem is selected
@property (readonly) AtlasSprite *selectedImage;
/// Sprite (image) that is displayed when the MenuItem is disabled
@property (readonly) AtlasSprite *disabledImage;

/** initializes a menu item with a normal, selected  and disabled image 
 with target/selector */
- (id)initFromNormalSprite:(AtlasSprite*)value
			selectedSprite:(AtlasSprite*)value2
			disabledSprite:(AtlasSprite*)value3
					target:(id)r
				  selector:(SEL)s;

/** creates a menu item with a normal and selected image*/
+ (id)itemFromNormalImage: (AtlasSprite*)value selectedImage:(AtlasSprite*)value2;
/** creates a menu item with a normal and selected image with target/selector */
+ (id)itemFromNormalImage: (AtlasSprite*)value selectedImage:(AtlasSprite*)value2 target:(id)r selector:(SEL)s;
/** creates a menu item with a normal,selected  and disabled image with target/selector */
+ (id)itemFromNormalImage: (AtlasSprite*)value
			selectedImage:(AtlasSprite*)value2
			disabledImage:(AtlasSprite*)value3
				   target:(id)r
				 selector:(SEL) s;
@end
