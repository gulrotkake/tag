//
//  StatusFetcher.m
//  Popup
//
//  Created by Michael Mortensen on 12/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StatusStore.h"
#import "Utilities.h"
#import "config.h"
#import "CHCSVParser.h"

@interface StatusStore () 
@property (assign) id<StatusListener> listener;
@property (assign) NSUInteger fetchStatus;
@property (retain) NSString *filename;
@property (retain) NSTimer *timer;
@end

@implementation StatusStore
@synthesize listener, timer;

static NSString* mkdir(NSString *filePath) {
    NSString *directoryPath = [filePath stringByDeletingLastPathComponent];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory;

    if (![fileManager fileExistsAtPath:directoryPath isDirectory:&isDirectory] || !isDirectory) {
        NSError *error = nil;
        BOOL success = [fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:&error];

        if (!success) {
            return [error localizedDescription];
        }
    }
    return nil;
}

- (id) initWithListenerAndKey:(id<StatusListener>)inListener key:(NSString *)inKey
{
    self = [super init];
    self.listener = inListener;
    self.timer = nil;
    self.filename = [NSString stringWithFormat:@"%@/.tag/tag.csv", NSHomeDirectory()];
    NSString *error = mkdir(self.filename);
    if (error) {
        [self.listener failedMiserably:error];
    }
    return self;
}

- (void) dealloc {
    if (self.timer && [self.timer isValid]) {
        [self.timer invalidate];
    }
    self.timer = nil;
    self.filename = nil;
    [super dealloc];
}

+ (NSString*) removeDoubleQuotes:(NSString*) input {
    if ([input length] < 2 || !([input hasPrefix:@"\""] && [input hasSuffix:@"\""])) {
        return input;
    }
    
    NSRange range = NSMakeRange(1, [input length] - 2);
    return [input substringWithRange:range];
}

- (void) addEntry:(NSDate *)timestamp tags:(NSArray*)tags description:(NSString *)description {
    // Get the last entry from the CSV file
    NSArray *csvData = [self getCSVData];
    NSArray *lastEntry = [csvData lastObject];
    
    if (lastEntry && [[lastEntry objectAtIndex:1] length] == 0) { // We need to close the previous entry, rewrite the CSV file
        CHCSVWriter *writer = [[[CHCSVWriter alloc] initForWritingToCSVFile:self.filename] autorelease];
        for (int i = 0; i < [csvData count]-1; ++i) {
            NSArray *fields = [csvData objectAtIndex:i];
            [writer writeLineOfFields:[NSArray arrayWithObjects:[fields objectAtIndex:0], [fields objectAtIndex:1], [fields objectAtIndex:2], [StatusStore removeDoubleQuotes:[fields objectAtIndex:3]], nil]];
        }

        // Write a new entry for the last line
        [writer writeLineOfFields:[NSArray arrayWithObjects:[lastEntry objectAtIndex:0], [Utilities getUTCDate:timestamp], [lastEntry objectAtIndex:2], [StatusStore removeDoubleQuotes:[lastEntry objectAtIndex:3]], nil]];
        [writer closeStream];
    }

    // If tags or description are set, we'll be writing a brand new field.
    if ([tags count] > 0 || [description length] > 0) {
        NSOutputStream *csvStream = [NSOutputStream outputStreamToFileAtPath:self.filename append:YES];
        CHCSVWriter *writer = [[[CHCSVWriter alloc] initWithOutputStream:csvStream encoding:NSUTF8StringEncoding delimiter:','] autorelease];
        [writer writeLineOfFields:[NSArray arrayWithObjects:[Utilities getUTCDate:timestamp], @"", [tags componentsJoinedByString:@" "], description, nil]];
        [writer closeStream];
    }
}

- (NSArray *) getCSVData {
    return [NSArray arrayWithContentsOfCSVURL:[NSURL fileURLWithPath:self.filename]];
}

- (void) getStatus {
    // Load hours csv
    NSDate *now = [NSDate date];
    NSDate *startOfDay = [Utilities getStartOfDay:now];
    NSArray *lines = [self getCSVData];

    double secondsWorked = 0.0;

    // Read backwards from the ledger until we find an entry that stops before today.
    for (id line in [lines reverseObjectEnumerator]) {
        NSDate *entryEnd;
        if ([[line objectAtIndex:1] length]) {
            entryEnd = [Utilities getDateFromUTCTimestamp:[line objectAtIndex:1]];
        } else {
            entryEnd = now;
        }

        if ([entryEnd compare:startOfDay] == NSOrderedAscending) {
            break;
        }

        // Get the max of startOfDay and entryStart
        NSDate *maxEntry = [startOfDay laterDate:[Utilities getDateFromUTCTimestamp:[line objectAtIndex:0]]];

        // Get the elapsed time for the given entry.
        secondsWorked += [entryEnd timeIntervalSinceDate:maxEntry];
    }

    bool working = lines.count > 0 && [[[lines lastObject] objectAtIndex:1] length] == 0;
    //NSString *entry = working? [[lines lastObject] objectAtIndex:0] : [Utilities getUTCDate:now];

    int hours = secondsWorked/(3600);
    int minutes = secondsWorked/(60) - hours*60;

    NSLog(@"Minutes worked: %f", secondsWorked / 60);
    [listener statusChanged:working hours:hours minutes:minutes];
}

- (void) pollStatus:(NSTimer*)theTimer {
    [self getStatus];
    [self stopPolling];
    [self startPolling];
}

- (void) fetchImmediatelyIfNotFetching
{
    if (self.timer) [self.timer fire];
}

- (void) startPolling {
    if (self.timer) [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(pollStatus:) userInfo:nil repeats:NO];
}

- (void) stopPolling {
    if (self.timer) [self.timer invalidate];
    self.timer = nil;
}

@end
