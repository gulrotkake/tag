#import <Foundation/Foundation.h>

@interface Utilities : NSObject

+ (NSString*)getUTCDate:(NSDate*)localDate;
+ (NSDate*)getStartOfDay:(NSDate*)date;
+ (NSDate*)getDateFromUTCTimestamp:(NSString*)date;

@end
