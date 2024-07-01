//
//  Entry.m
//  Popup
//
//  Created by Michael Mortensen on 12/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Entry.h"
#import "ISO8601DateFormatter.h"
#import "Utilities.h"
#import "config.h"

@implementation Entry

@synthesize tags;
@synthesize description;
@synthesize working;
@synthesize timestamp;

- (id) init {
    self = [super init];
    if (self) {
        self.tags = nil;
        self.description = nil;
        self.working = NO;
        self.timestamp = nil;
    }
    return self;
    
}

- (void) dealloc {
    self.tags = nil;
    self.description = nil;
    self.timestamp = nil;
    [super dealloc];
}
@end
