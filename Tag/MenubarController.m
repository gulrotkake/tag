#import "MenubarController.h"

@interface MenubarController ()
@property(assign, nonatomic) BOOL inError;
@property(assign, nonatomic) BOOL oldStatus;
@property(assign, nonatomic) BOOL highlighted;
@end

@implementation MenubarController

@synthesize inError;
@synthesize oldStatus;
@synthesize statusItem;

#pragma mark -

- (id)init {
    self = [super init];
    if (self != nil) {
        // Install status item into the menu bar
        self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:STATUS_ITEM_VIEW_WIDTH];
        statusItem.button.image = [NSImage imageNamed:@"StatusInactive"];
        statusItem.button.alternateImage = [NSImage imageNamed:@"StatusHighlighted"];
        statusItem.button.action = @selector(togglePanel:);
        self.inError = NO;
    }
    return self;
}

- (void)dealloc {
    self.inError = NO;
    [[NSStatusBar systemStatusBar] removeStatusItem:self.statusItem];
    self.statusItem = nil;
    [super dealloc];
}

#pragma mark -

- (BOOL)hasActiveIcon {
    return self.highlighted;
}

- (void)setHasActiveIcon:(BOOL)flag {
    self.highlighted = flag;
    [self.statusItem.button setHighlighted:self.highlighted];
}

- (void)setError:(NSString*)error {
    if (error) {
        inError = YES;
        statusItem.button.image = [NSImage imageNamed:@"StatusFailed"];
        [statusItem.button setToolTip:error];
    } else {
        [statusItem.button setToolTip:@""];
        inError = NO;
    }
}

- (void)setStatus:(BOOL)working {
    if (working == oldStatus || inError)
        return;
    oldStatus = working;
    if (working) {
        statusItem.button.image = [NSImage imageNamed:@"Status"];
    } else {
        statusItem.button.image = [NSImage imageNamed:@"StatusInactive"];
    }
}
@end
