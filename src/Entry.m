#import "Entry.h"

@implementation Entry

@synthesize tags;
@synthesize description;
@synthesize working;
@synthesize timestamp;

- (id)init {
    self = [super init];
    if (self) {
        self.tags = nil;
        self.description = nil;
        self.working = NO;
        self.timestamp = nil;
    }
    return self;
}

- (void)dealloc {
    self.tags = nil;
    self.description = nil;
    self.timestamp = nil;
    [super dealloc];
}
@end
