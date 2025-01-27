#import "PanelController.h"
#import "BackgroundView.h"
#import "Entry.h"
#import "MenubarController.h"
#import "Utilities.h"

#define OPEN_DURATION .15
#define CLOSE_DURATION .1

#define SEARCH_INSET 20
#define TOP_INSET 28
#define POPUP_HEIGHT 295
#define PANEL_WIDTH 280
#define MENU_ANIMATION_DURATION .1

#pragma mark -

@interface PanelController () <NSTextViewDelegate>
@property(retain, nonatomic) Entry* entry;
@property(assign, nonatomic) BOOL disabled;
@property(copy, nonatomic) NSString* totalString;
@property(copy, nonatomic) NSString* lastString;
@property(assign, nonatomic) BOOL backspaceDetected;
@property(retain, nonatomic) NSSet* completionTags;
@end

@implementation PanelController

@synthesize backgroundView = _backgroundView;
@synthesize delegate = _delegate;
@synthesize inputText = _inputText;
@synthesize inputView = _inputView;

@synthesize tags;
@synthesize tagsLabel;
@synthesize when;
@synthesize whenLabel;
@synthesize sum;
@synthesize totalString;
@synthesize descriptionText;
@synthesize descriptionLabel;
@synthesize box;
@synthesize signedIn;
@synthesize entry;
@synthesize disabled;
@synthesize lastString;

#pragma mark -

- (id)initWithDelegate:(id<PanelControllerDelegate>)delegate tags:(NSSet*)tags {
    self = [super initWithWindowNibName:@"Panel"];
    if (self != nil) {
        _delegate = delegate;
        self.signedIn = NO;
        self.disabled = YES;
        self.totalString = nil;
        self.entry = [[Entry alloc] init];
        self.completionTags = tags;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSControlTextDidChangeNotification object:self.inputText];
    self.totalString = nil;
    self.lastString = nil;
    self.entry = nil;
    self.completionTags = nil;
}

#pragma mark -

- (void)awakeFromNib {
    [super awakeFromNib];

    // Make a fully skinned panel
    NSPanel* panel = (id)[self window];
    [panel setAcceptsMouseMovedEvents:YES];
    [panel setLevel:NSPopUpMenuWindowLevel];
    [panel setOpaque:NO];
    [panel setBackgroundColor:[NSColor clearColor]];

    [sum setStringValue:totalString ?: @""];

    // Resize panel
    NSRect panelRect = [[self window] frame];
    panelRect.size.height = POPUP_HEIGHT;
    [[self window] setFrame:panelRect display:NO];
    [self.inputText setDelegate:self];
    [self.inputText setTagCompletions:[self.completionTags allObjects]];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(parseInput) name:NSControlTextDidChangeNotification object:self.inputText];

    if (disabled)
        [self disable];
    else
        [self enable];
}

#pragma mark - Public accessors

- (BOOL)hasActivePanel {
    return _hasActivePanel;
}

- (BOOL)textView:(NSTextView*)aTextView doCommandBySelector:(SEL)aSelector {
    if (aSelector == @selector(insertNewline:)) {
        if ([_delegate validEntry:[entry timestamp]]) {
            [_delegate registerEntry:[entry timestamp] tags:[entry tags] description:[entry description]];
            [descriptionText setStringValue:@""];
            [_inputText setString:@""];
            [tags setStringValue:@""];
            [when setStringValue:@""];
            [self setHasActivePanel:NO];
            [self closePanel];
            return YES;
        } else {
            return NO;
        }
    }

    if (aSelector == @selector(deleteBackward:) || aSelector == @selector(deleteForward:)) {
        self.backspaceDetected = [self.inputText textStorage].length > 0;
    }
    return NO;
}

- (void)enable {
    self.disabled = NO;
    NSArray* fields = [NSArray arrayWithObjects:tagsLabel, whenLabel, tags, when, descriptionLabel, descriptionText, nil];
    for (NSTextField* field in fields) {
        [field setEnabled:YES];
        [field setTextColor:[NSColor controlTextColor]];
    }
    [when setHidden:NO];
    [_inputText setEditable:YES];
}

- (void)disable {
    self.disabled = YES;
    NSArray* fields = [NSArray arrayWithObjects:tagsLabel, whenLabel, tags, when, descriptionLabel, descriptionText, nil];
    for (NSTextField* field in fields) {
        [field setEnabled:NO];
        [field setTextColor:[NSColor disabledControlTextColor]];
    }
    [when setHidden:YES];
    [_inputText setEditable:NO];
    [box setTitle:@""];
}

- (void)setTotal:(NSString*)total {
    self.totalString = total;
    [sum setStringValue:totalString];
}

- (void)setHasActivePanel:(BOOL)flag {
    if (_hasActivePanel != flag) {
        _hasActivePanel = flag;

        if (_hasActivePanel) {
            [self openPanel];
        } else {
            [self closePanel];
        }
    }
}

#pragma mark - NSWindowDelegate

- (void)windowWillClose:(NSNotification*)notification {
    self.hasActivePanel = NO;
}

- (void)windowDidResignKey:(NSNotification*)notification;
{
    if ([[self window] isVisible]) {
        self.hasActivePanel = NO;
    }
}

- (void)windowDidResize:(NSNotification*)notification {
    NSWindow* panel = [self window];
    NSRect statusRect = [self statusRectForWindow:panel];
    NSRect panelRect = [panel frame];

    CGFloat statusX = roundf(NSMidX(statusRect));
    CGFloat panelX = statusX - NSMinX(panelRect);

    self.backgroundView.arrowX = panelX;

    NSRect inputTextRect = [self.inputView frame];
    inputTextRect.size.width = NSWidth([self.backgroundView bounds]) - SEARCH_INSET * 2;
    inputTextRect.origin.x = SEARCH_INSET;
    inputTextRect.origin.y = NSHeight([self.backgroundView bounds]) - ARROW_HEIGHT - TOP_INSET - NSHeight(inputTextRect);

    if (NSIsEmptyRect(inputTextRect)) {
        [self.inputView setHidden:YES];
    } else {
        [self.inputView setFrame:inputTextRect];
        [self.inputView setHidden:NO];
    }
    [sum sizeToFit];
    NSRect frame = sum.frame;
    CGFloat offsetX = NSWidth([self.backgroundView bounds]) - frame.size.width - SEARCH_INSET;
    frame.origin.x = offsetX;
    [sum setFrame:frame];
}

- (void)setWorking:(BOOL)working {
    self.signedIn = working;
}

#pragma mark - Keyboard

- (void)cancelOperation:(id)sender {
    self.hasActivePanel = NO;
}

- (NSDate*)parseTimeString:(NSString*)input range:(NSRange*)range {
    if (!input || [input length] == 0)
        return [NSDate date];

    NSError* error;
    NSDataDetector* guess = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeDate error:&error];
    NSArray* matches = [guess matchesInString:input options:0 range:NSMakeRange(0, [input length])];

    // For now we only care about the first match and its location. Improve later
    if ([matches count] > 0 && [[matches objectAtIndex:0] range].location < 7) {
        *range = [[matches objectAtIndex:0] range];
        return ((NSTextCheckingResult*)[matches objectAtIndex:0]).date;
    }
    return [NSDate date];
}

- (NSArray*)parseInputForTags:(NSString*)input {
    NSError* error;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"#([\\+|\\w|\\d]+)\\b" options:0 error:&error];
    NSArray* matches = [regex matchesInString:input options:0 range:NSMakeRange(0, [input length])];
    NSMutableArray* tagsInInput = [NSMutableArray arrayWithCapacity:[matches count]];
    for (NSTextCheckingResult* match in matches) {
        NSRange range = [match rangeAtIndex:1];
        [tagsInInput addObject:[input substringWithRange:range]];
    }
    return tagsInInput;
}

- (void)parseInput {
    BOOL textDidNotChange = [lastString isEqualToString:[[_inputText textStorage] string]];

    // Nothing else changed, ignore pointless parsing.
    if (textDidNotChange) {
        self.backspaceDetected = false;
        return;
    }

    lastString = [[[_inputText textStorage] string] copy];
    NSString* inString = lastString;

    NSRange dateRange = NSMakeRange(NSNotFound, 0);
    NSDate* date = [self parseTimeString:inString range:&dateRange];
    entry.timestamp = date;
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDoesRelativeDateFormatting:YES];

    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [when setStringValue:[dateFormatter stringFromDate:date]];

    NSArray* inputTags = [self parseInputForTags:inString];
    entry.tags = inputTags;
    [tags setStringValue:[inputTags componentsJoinedByString:@" "]];

    NSString* descriptionString = inString;

    if (dateRange.location != NSNotFound) {
        descriptionString = [descriptionString substringFromIndex:dateRange.location + dateRange.length];
    }

    NSError* error = nil;
    NSRegularExpression* keepTags = [NSRegularExpression regularExpressionWithPattern:@"(^|\\s)#(\\w+)" options:0 error:&error];
    NSRegularExpression* rmTags = [NSRegularExpression regularExpressionWithPattern:@"(^|\\s)##\\w+" options:0 error:&error];
    descriptionString = [rmTags stringByReplacingMatchesInString:descriptionString options:0 range:NSMakeRange(0, descriptionString.length) withTemplate:@""];
    descriptionString = [keepTags stringByReplacingMatchesInString:descriptionString options:0 range:NSMakeRange(0, descriptionString.length) withTemplate:@"$1$2"];
    descriptionString = [descriptionString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    entry.description = descriptionString;
    [descriptionText setStringValue:descriptionString];
    BOOL hasDescription = (descriptionString && [descriptionString length] > 0);
    BOOL hasTags = (tags && [inputTags count] > 0);
    entry.working = YES;
    [box.titleCell setTextColor:NSColor.textColor];
    if (hasDescription || hasTags) {
        if (signedIn) {
            [box setTitle:NSLocalizedString(@"Press enter to continue with task:", @"Changing tasks, no status change")];
        } else {
            [box setTitle:NSLocalizedString(@"Press enter to start working on task:", @"Start task, changes state to working")];
        }
    } else {
        if (signedIn) {
            entry.working = NO;
            [box setTitle:NSLocalizedString(@"Pressing enter will sign you out", @"Stop task, change state to not working")];
        } else {
            [box setTitle:NSLocalizedString(@"Enter to start working from timestamp:", @"Start working from the specified timestamp")];
        }
    }

    if (![_delegate validEntry:[entry timestamp]]) {
        [box.titleCell setTextColor:NSColor.redColor];
        [box setTitle:NSLocalizedString(@"Timestamp not greater than previous", @"Timestamp not greater than previous")];
    }

    if (self.backspaceDetected) {
        self.backspaceDetected = false;
    } else if ([inString hasSuffix:@"#"]) {
        [self.inputText complete:nil];
    }
}

- (void)textDidChange:(NSNotification*)aNotification {
    [self parseInput];
}

#pragma mark - Public methods

- (NSRect)statusRectForWindow:(NSWindow*)window {
    NSRect screenRect = [[window screen] frame];
    NSRect statusRect = NSZeroRect;

    NSStatusBarButton* statusItemButton = nil;
    if ([self.delegate respondsToSelector:@selector(statusItemButtonForPanelController:)]) {
        statusItemButton = [self.delegate statusItemButtonForPanelController:self];
    }

    if (statusItemButton) {
        NSRect statusItemFrame = statusItemButton.window.frame;
        statusRect.size = NSMakeSize(STATUS_ITEM_VIEW_WIDTH, [[NSStatusBar systemStatusBar] thickness]);
        statusRect.origin.x = NSMidX(statusItemFrame) - NSWidth(statusRect) / 2;
        statusRect.origin.y = NSMinY(statusItemFrame) - NSHeight(statusRect);
    } else {
        statusRect.size = NSMakeSize(STATUS_ITEM_VIEW_WIDTH, [[NSStatusBar systemStatusBar] thickness]);
        statusRect.origin.x = roundf((NSWidth(screenRect) - NSWidth(statusRect)) / 2);
        statusRect.origin.y = NSHeight(screenRect) - NSHeight(statusRect) * 2;
    }
    return statusRect;
}

- (void)openPanel {
    NSWindow* panel = [self window];

    NSRect screenRect = [[panel screen] frame];
    NSRect statusRect = [self statusRectForWindow:panel];

    NSRect panelRect = [panel frame];
    panelRect.size.width = PANEL_WIDTH;
    panelRect.origin.x = roundf(NSMidX(statusRect) - NSWidth(panelRect) / 2);
    panelRect.origin.y = NSMaxY(statusRect) - NSHeight(panelRect);

    if (NSMaxX(panelRect) > (NSMaxX(screenRect) - ARROW_HEIGHT))
        panelRect.origin.x -= NSMaxX(panelRect) - (NSMaxX(screenRect) - ARROW_HEIGHT);

    [NSApp activateIgnoringOtherApps:NO];
    [panel setAlphaValue:0];
    [panel setFrame:statusRect display:YES];
    [panel makeKeyAndOrderFront:nil];

    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:OPEN_DURATION];
    [[panel animator] setFrame:panelRect display:YES];
    [[panel animator] setAlphaValue:1];
    [NSAnimationContext endGrouping];

    [self.inputText setTagCompletions:[self.completionTags allObjects]];
    [self parseInput];
    [panel performSelector:@selector(makeFirstResponder:) withObject:self.inputText afterDelay:OPEN_DURATION];
}

- (void)closePanel {
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:CLOSE_DURATION];
    [[[self window] animator] setAlphaValue:0];
    [NSAnimationContext endGrouping];

    dispatch_after(dispatch_walltime(NULL, NSEC_PER_SEC * CLOSE_DURATION * 2), dispatch_get_main_queue(), ^{
      [self.window orderOut:nil];
    });

    [NSApp hide:self];
}

@end
