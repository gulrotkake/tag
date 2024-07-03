#import "StatusItemView.h"
#import "Utilities.h"

@interface StatusItemView ()
@property(nonatomic, retain) NSArray* images;
@property(nonatomic, retain) NSArray* alternateImages;
@property(nonatomic, assign) NSUInteger index;
@property(nonatomic, retain) NSTimer* timer;
@end

@implementation StatusItemView

@synthesize statusItem;
@synthesize image;
@synthesize alternateImage;
@synthesize isHighlighted;
@synthesize action;
@synthesize target;
@synthesize globalRect;
#pragma mark -

- (id)initWithStatusItem:(NSStatusItem*)aStatusItem {
    CGFloat itemWidth = [aStatusItem length];
    CGFloat itemHeight = [[NSStatusBar systemStatusBar] thickness];
    NSRect itemRect = NSMakeRect(0.0, 0.0, itemWidth, itemHeight);
    self = [super initWithFrame:itemRect];

    if (self != nil) {
        self.statusItem = aStatusItem;
    }
    return self;
}

- (void)dealloc {
    self.statusItem = nil;
    self.image = nil;
    self.alternateImage = nil;
    [super dealloc];
}

#pragma mark -

- (void)drawRect:(NSRect)dirtyRect {
    [self.statusItem drawStatusBarBackgroundInRect:dirtyRect withHighlight:self.isHighlighted];

    NSImage* icon = self.isHighlighted ? self.alternateImage : image;
    NSSize iconSize = [icon size];
    NSRect bounds = self.bounds;
    CGFloat iconX = roundf((NSWidth(bounds) - iconSize.width) / 2);
    CGFloat iconY = roundf((NSHeight(bounds) - iconSize.height) / 2);
    NSPoint iconPoint = NSMakePoint(iconX, iconY);
    [icon compositeToPoint:iconPoint operation:NSCompositingOperationSourceOver];
}

- (void)activate {
    [NSApp sendAction:self.action to:self.target from:self];
}

#pragma mark -
#pragma mark Mouse tracking

- (void)mouseDown:(NSEvent*)theEvent {
    [NSApp sendAction:self.action to:self.target from:self];
}

#pragma mark -
#pragma mark Accessors

- (void)setHighlighted:(BOOL)newFlag {
    if (isHighlighted == newFlag)
        return;
    isHighlighted = newFlag;
    [self setNeedsDisplay:YES];
}

#pragma mark -

- (void)setImage:(NSImage*)newImage {
    if (image != newImage) {
        //_image = [Utilities scaleImage:newImage longSide:[[NSStatusBar systemStatusBar] thickness]-5];// newImage;
        [image release];
        [newImage retain];
        image = newImage;
        [self setNeedsDisplay:YES];
    }
}

- (void)setAlternateImage:(NSImage*)newImage {
    if (alternateImage != newImage) {
        //_alternateImage = [Utilities scaleImage:newImage longSide:[[NSStatusBar systemStatusBar] thickness]-5];// newImage;
        [alternateImage release];
        [newImage retain];
        alternateImage = newImage;
        if (self.isHighlighted) {
            [self setNeedsDisplay:YES];
        }
    }
}

#pragma mark -

- (NSRect)globalRect {
    NSRect frame = [self frame];
    frame.origin = [self.window convertPointToScreen:frame.origin];
    return frame;
}

@end
