#import <Foundation/Foundation.h>

@interface Entry : NSObject
@property(retain) NSDate* timestamp;
@property(assign) BOOL working;
@property(retain) NSArray* tags;
@property(retain) NSString* description;
@end
