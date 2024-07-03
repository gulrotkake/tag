#import "MenubarController.h"
#import "StatusItemView.h"

@interface MenubarController ()
@property(assign, nonatomic) BOOL inError;
@property(assign, nonatomic) BOOL oldStatus;
@end

@implementation MenubarController

@synthesize statusItemView;
@synthesize inError;
@synthesize oldStatus;
@synthesize statusItem;

#pragma mark -

- (id)init {
    self = [super init];
    if (self != nil) {
        // Install status item into the menu bar
        self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:STATUS_ITEM_VIEW_WIDTH];
        self.statusItemView = [[[StatusItemView alloc] initWithStatusItem:statusItem] autorelease];
        statusItem.button.image = [NSImage imageNamed:@"StatusInactive"];
        statusItem.button.alternateImage = [NSImage imageNamed:@"StatusHighlighted"];
        //statusItem.button.action = @selector(togglePanel:);
        [statusItem.button addSubview:statusItemView];
        statusItemView.action = @selector(togglePanel:);
        self.inError = NO;
    }
    return self;
}

- (void)dealloc {
    self.inError = NO;
    [[NSStatusBar systemStatusBar] removeStatusItem:self.statusItem];
    self.statusItem = nil;
    self.statusItemView = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Public accessors

- (NSStatusItem*)statusItem {
    return self.statusItemView.statusItem;
}

#pragma mark -

- (BOOL)hasActiveIcon {
    return self.statusItemView.isHighlighted;
}

- (void)setHasActiveIcon:(BOOL)flag {
    self.statusItemView.isHighlighted = flag;
}

- (void)setError:(NSString*)error {
    if (error) {
        inError = YES;
        statusItemView.image = [NSImage imageNamed:@"StatusFailed"];
        [statusItemView setToolTip:error];
    } else {
        [statusItemView setToolTip:@""];
        inError = NO;
    }
}

- (void)setStatus:(BOOL)working {
    if (working == oldStatus && !inError)
        return;
    oldStatus = working;
    if (inError) {
        [self setError:nil];
    }
    if (working) {
        statusItemView.image = [NSImage imageNamed:@"Status"];
    } else {
        statusItemView.image = [NSImage imageNamed:@"StatusInactive"];
    }
}
@end
