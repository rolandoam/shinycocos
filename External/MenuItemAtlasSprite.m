#import "MenuItemAtlasSprite.h"

@implementation MenuItemAtlasSprite

@synthesize selectedImage, normalImage, disabledImage;

+ (id)itemFromNormalImage:(AtlasSprite*)value selectedImage:(AtlasSprite*)value2
{
	return [self itemFromNormalImage:value selectedImage:value2 disabledImage:nil target:nil selector:nil];
}

+ (id)itemFromNormalImage:(AtlasSprite*)value selectedImage:(AtlasSprite*)value2 target:(id)t selector:(SEL)s
{
	return [self itemFromNormalImage:value selectedImage:value2 disabledImage:nil target:t selector:s];
}

+ (id)itemFromNormalImage:(AtlasSprite*)value selectedImage:(AtlasSprite*)value2 disabledImage:(AtlasSprite*)value3
{
	return [[[self alloc] initFromNormalSprite:value selectedSprite:value2 disabledSprite:value3 target:nil selector:nil] autorelease];
}

+ (id)itemFromNormalImage:(AtlasSprite*)value selectedImage:(AtlasSprite*)value2 disabledImage:(AtlasSprite*)value3 target:(id)t selector:(SEL)s
{
	return [[[self alloc] initFromNormalSprite:value selectedSprite:value2 disabledSprite:value3 target:t selector:s] autorelease];
}

- (id)initFromNormalSprite:(AtlasSprite*)normalI selectedSprite:(AtlasSprite*)selectedI disabledSprite:(AtlasSprite*)disabledI target:(id)t selector:(SEL)sel
{
	if (!(self=[super initWithTarget:t selector:sel]))
		return nil;
	
	normalImage = normalI;
	selectedImage = selectedI;
	disabledImage = disabledI;
	
	[normalImage setOpacity:opacity];
	if (selectedImage) {
		[selectedImage setOpacity:opacity];
		[selectedImage setVisible:FALSE];
	}
	if (disabledImage) {
		[disabledImage setOpacity:opacity];
		[disabledImage setVisible:FALSE];
	}
	
	CGSize s = [normalImage contentSize];
	transformAnchor = ccp( s.width/2, s.height/2 );
	
	return self;
}

- (void)dealloc
{
	[normalImage release];
	if (selectedImage) [selectedImage release];
	if (disabledImage) [disabledImage release];
	[super dealloc];
}

- (void)selected
{
	if (isEnabled && selectedImage) 
	{	
		[normalImage setVisible:FALSE];
		[selectedImage setVisible:TRUE];
		selected = YES;
	}
}

- (void)unselected
{
	if (isEnabled && selectedImage) {		
		[normalImage setVisible:TRUE];
		[selectedImage setVisible:FALSE];
		selected = NO;
	}
}

- (void)setIsEnabled:(BOOL)enabled
{
	[super setIsEnabled:enabled];
	if (!disabledImage) return;
	
	if(!enabled)
	{
		[normalImage setVisible:FALSE];
		[selectedImage setVisible:FALSE];
		[disabledImage setVisible:TRUE];
	}
	else
	{
		[normalImage setVisible:TRUE];
		[disabledImage setVisible:FALSE];
	}
}

- (CGRect)rect
{
	CGSize s = [normalImage contentSize];
	CGRect r = CGRectMake(position.x - s.width/2, position.y - s.height/2, s.width, s.height);
	return r;
}

- (void)setPosition:(CGPoint)pos
{
	[super setPosition:pos];
	[normalImage setPosition:position];
	if (selectedImage)
		[selectedImage setPosition:position];
	if (disabledImage)
		[disabledImage setPosition:position];	
}

- (CGSize)contentSize
{
	return [normalImage contentSize];
}

- (void)draw
{
	return;
}

- (void) setOpacity: (GLubyte)newOpacity
{
	opacity = newOpacity;
	[normalImage setOpacity:opacity];
	if (selectedImage)
		[selectedImage setOpacity:opacity];
	if (disabledImage)
		[disabledImage setOpacity:opacity];
}

@end