#import "ApplicationDelegate.h"
#import <Carbon/Carbon.h>
#import "DDHotKeyCenter.h"
#import "StatusStore.h"
#import "config.h"

@interface ApplicationDelegate () <StatusListener>

@property(retain, nonatomic) StatusStore* statusFetcher;
@property(assign, nonatomic) BOOL firstFetch;
@property(retain) NSString* key;
@property(retain, nonatomic) NSMenu* statusMenu;

@end

@implementation ApplicationDelegate

@synthesize panelController = _panelController;
@synthesize menubarController = _menubarController;
@synthesize statusFetcher;
@synthesize firstFetch;
@synthesize key;
#pragma mark -

- (void)dealloc {
    [_panelController removeObserver:self forKeyPath:@"hasActivePanel"];
    self.statusFetcher = nil;
    self.menubarController = nil;
    self.panelController = nil;
    self.statusMenu = nil;
    self.key = nil;
    [super dealloc];
}

#pragma mark -

void* kContextActivePanel = &kContextActivePanel;

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context {
    if (context == kContextActivePanel) {
        self.menubarController.hasActiveIcon = self.panelController.hasActivePanel;
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - StatusListener

- (void)statusChanged:(BOOL)working hours:(int)hours minutes:(int)minutes {
    if (firstFetch) {
        firstFetch = NO;
        [_panelController enable];
        DDHotKeyCenter* c = [[[DDHotKeyCenter alloc] init] autorelease];
        if (![c registerHotKeyWithKeyCode:kVK_Space modifierFlags:(NSEventModifierFlagShift | NSEventModifierFlagCommand) target:self action:@selector(hotkeyWithEvent:) object:nil]) {
            [self failedMiserably:@"Hotkey registration failed"];
        }
    }
    NSString* total = nil;
    if (minutes > 0 || hours > 0) {
        if (hours > 0) {
            total = [NSString stringWithFormat:@"Today: %dh %dm", hours, minutes];
        } else {
            total = [NSString stringWithFormat:@"Today: %dm", minutes];
        }
    } else {
        total = @"";
    }
    [_panelController setTotal:total];
    [_panelController setWorking:working];
    [_menubarController setStatus:working];
}

- (void)failedMiserably:(NSString*)error {
    NSLog(@"Failed %@", error);
    [_menubarController setError:error];
}

#pragma mark - NSApplicationDelegate

- (void)hotkeyWithEvent:(NSEvent*)hkEvent {
    if (![_menubarController hasActiveIcon]) {
        [[NSApplication sharedApplication] sendAction:_menubarController.statusItem.button.action to:_menubarController.statusItem.button.target from:_menubarController.statusItem.button];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification*)notification {
    // Install icon into the menu bar
    firstFetch = YES;
    self.menubarController = [[[MenubarController alloc] init] autorelease];
    self.statusFetcher = [[[StatusStore alloc] initWithListenerAndKey:self key:key] autorelease];
    self.statusMenu = [[[NSMenu alloc] init] autorelease];
    [self.statusMenu addItemWithTitle:NSLocalizedString(@"Quit", @"Action to exit program") action:@selector(quitClicked) keyEquivalent:@"q"];
    [[self panelController] setSignedIn:NO];
    [_menubarController setStatus:NO];
    [_panelController disable];
    [statusFetcher startPolling];
    [statusFetcher fetchImmediatelyIfNotFetching];
}

- (void)quitClicked {
    [NSApp terminate:self];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication*)sender {
    // Explicitly remove the icon from the menu bar
    self.menubarController = nil;
    return NSTerminateNow;
}

#pragma mark - Actions

- (IBAction)togglePanel:(id)sender {
    NSEvent* event = NSApp.currentEvent;
    if (event.type == NSEventTypeRightMouseDown || (event.modifierFlags & NSEventModifierFlagOption)) {
        self.menubarController.statusItem.menu = self.statusMenu;
        [self.menubarController.statusItem.button performClick:nil];
        self.menubarController.statusItem.menu = nil;
    } else {
        self.menubarController.hasActiveIcon = !self.menubarController.hasActiveIcon;
        self.panelController.hasActivePanel = self.menubarController.hasActiveIcon;
    }
}

#pragma mark - Public accessors

- (PanelController*)panelController {
    if (_panelController == nil) {
        _panelController = [[PanelController alloc] initWithDelegate:self tags:[self.statusFetcher getTags]];
        [_panelController addObserver:self forKeyPath:@"hasActivePanel" options:0 context:kContextActivePanel];
    }
    return _panelController;
}

#pragma mark - PanelControllerDelegate

- (NSStatusBarButton*)statusItemButtonForPanelController:(PanelController*)controller {
    return self.menubarController.statusItem.button;
}

- (void)registerEntry:(NSDate*)timestamp tags:(NSArray*)tags description:(NSString*)description {
    [self.statusFetcher addEntry:timestamp tags:tags description:description];
    [self.statusFetcher fetchImmediatelyIfNotFetching];
}

- (BOOL)validEntry:(NSDate*)timestamp {
    return [self.statusFetcher validEntry:timestamp];
}

@end
