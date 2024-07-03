//
//  StatusFetcher.h
//  Popup
//
//  Created by Michael Mortensen on 12/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol StatusListener <NSObject>
- (void)statusChanged:(BOOL)working hours:(int)hours minutes:(int)minutes;
- (void)failedMiserably:(NSString*)error;
@end

@interface StatusStore : NSObject

- (id)initWithListenerAndKey:(id<StatusListener>)listener key:(NSString*)key;
- (void)startPolling;
- (void)stopPolling;
- (void)fetchImmediatelyIfNotFetching;
- (void)addEntry:(NSDate*)timestamp tags:(NSArray*)tags description:(NSString*)description;
- (NSSet*)getTags;

@end
