#import "FocusableScrollView.h"

@implementation FocusableScrollView

- (void)drawRect:(NSRect)rect {
    [super drawRect:rect];

    NSSetFocusRingStyle(NSFocusRingOnly);
    NSRectFill([self bounds]);
}

@end
