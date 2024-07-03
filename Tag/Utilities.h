#import <Foundation/Foundation.h>

@interface Utilities : NSObject

+ (NSImage*)rotateImage:(NSImage*)image degrees:(CGFloat)deg;
+ (NSString*)getUTCDate:(NSDate*)localDate;
+ (NSDate*)getStartOfDay:(NSDate*)date;
+ (NSDate*)getDateFromUTCTimestamp:(NSString*)date;
+ (NSImage*)scaleImage:(NSImage*)image longSide:(CGFloat)longSide;
@end
