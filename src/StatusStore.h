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
- (BOOL)validEntry:(NSDate*)timestamp;
- (NSSet*)getTags;

@end
