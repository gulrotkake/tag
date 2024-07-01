#import "StatusItemView.h"
#import "Utilities.h"

@interface StatusItemView ()
@property (nonatomic, retain) NSArray *images;
@property (nonatomic, retain) NSArray *alternateImages;
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, retain) NSTimer *timer;
@end

@implementation StatusItemView

@synthesize statusItem;
@synthesize image;
@synthesize alternateImage;
@synthesize isHighlighted;
@synthesize action;
@synthesize target;
@synthesize images;
@synthesize alternateImages;
@synthesize index;
@synthesize timer;
@synthesize globalRect;
#pragma mark -

- (id)initWithStatusItem:(NSStatusItem *)aStatusItem
{
    CGFloat itemWidth = [aStatusItem length];
    CGFloat itemHeight = [[NSStatusBar systemStatusBar] thickness];
    NSRect itemRect = NSMakeRect(0.0, 0.0, itemWidth, itemHeight);
    self = [super initWithFrame:itemRect];
    
    if (self != nil) {
        self.statusItem = aStatusItem;
        self.images = nil;
        self.alternateImages = nil;
        self.index = 0;
        self.timer = nil;
    }
    return self;
}

- (void) dealloc
{
    if (self.timer) {
        [timer invalidate];
        self.timer = nil;
    }
    self.alternateImages=nil;
    self.images=nil;
    self.statusItem = nil;
    self.image = nil;
    self.alternateImage = nil;
    [super dealloc];
}

- (void) rotate
{
    index += 1;
    index %= [images count];
    [self setNeedsDisplay:YES];
}

- (void) startAnimation {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(rotate) userInfo:nil repeats:YES];
}

- (void) stopAnimation {
    [self.timer invalidate];
    self.timer = nil;
    index = 0;
    [self setNeedsDisplay:YES];
}

#pragma mark -

- (void)drawRect:(NSRect)dirtyRect
{
	[self.statusItem drawStatusBarBackgroundInRect:dirtyRect withHighlight:self.isHighlighted];
    
    NSImage *icon = self.isHighlighted ? self.alternateImage : [images objectAtIndex:index];
    NSSize iconSize = [icon size];
    NSRect bounds = self.bounds;
    CGFloat iconX = roundf((NSWidth(bounds) - iconSize.width) / 2);
    CGFloat iconY = roundf((NSHeight(bounds) - iconSize.height) / 2);
    NSPoint iconPoint = NSMakePoint(iconX, iconY);
    [icon compositeToPoint:iconPoint operation:NSCompositingOperationSourceOver];
}

- (void) activate
{
    [NSApp sendAction:self.action to:self.target from:self];
}

#pragma mark -
#pragma mark Mouse tracking

- (void)mouseDown:(NSEvent *)theEvent
{
    [NSApp sendAction:self.action to:self.target from:self];
}

#pragma mark -
#pragma mark Accessors

- (void)setHighlighted:(BOOL)newFlag
{
    if (isHighlighted == newFlag) return;
    isHighlighted = newFlag;
    [self setNeedsDisplay:YES];
}

#pragma mark -

- (void)setImage:(NSImage *)newImage
{
    if (image != newImage) {
        //_image = [Utilities scaleImage:newImage longSide:[[NSStatusBar systemStatusBar] thickness]-5];// newImage;
        [image release];
        [newImage retain];
        image = newImage;
        self.images = [NSArray arrayWithObjects:image,
                       [Utilities rotateImage:image degrees:-15],
                       [Utilities rotateImage:image degrees:-30],
                       [Utilities rotateImage:image degrees:-45],
                       [Utilities rotateImage:image degrees:-60],
                       [Utilities rotateImage:image degrees:-75],
                       nil];
        [self setNeedsDisplay:YES];
    }
}

- (void)setAlternateImage:(NSImage *)newImage
{
    if (alternateImage != newImage) {
        //_alternateImage = [Utilities scaleImage:newImage longSide:[[NSStatusBar systemStatusBar] thickness]-5];// newImage;
        [alternateImage release];
        [newImage retain];
        alternateImage = newImage;
        self.alternateImages = [NSArray arrayWithObjects:alternateImage,
                                [Utilities rotateImage:alternateImage degrees:30],
                                [Utilities rotateImage:alternateImage degrees:60],
                                [Utilities rotateImage:alternateImage degrees:90],
                                [Utilities rotateImage:alternateImage degrees:120],
                                [Utilities rotateImage:alternateImage degrees:150],
                                nil];
        if (self.isHighlighted) {
            [self setNeedsDisplay:YES];
        }
    }
}

#pragma mark -

- (NSRect)globalRect
{
    NSRect frame = [self frame];
    frame.origin = [self.window convertPointToScreen:frame.origin];
    //frame.origin = [self.window convertBaseToScreen:frame.origin];
    return frame;
}

@end
