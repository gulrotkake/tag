#import "Utilities.h"
#import "ISO8601DateFormatter.h"

@implementation Utilities

+ (NSString*)getUTCDate:(NSDate*)localDate {
    NSDateFormatter* dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    NSString* dateString = [dateFormatter stringFromDate:localDate];
    return dateString;
}

+ (NSDate*)getDateFromUTCTimestamp:(NSString*)date {
    ISO8601DateFormatter* formatter = [[[ISO8601DateFormatter alloc] init] autorelease];
    return [formatter dateFromString:date];
}

+ (NSDate*)getStartOfDay:(NSDate*)date {
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSCalendar* gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian] autorelease];
    NSDateComponents* components = [gregorian components:unitFlags fromDate:date];
    components.hour = 0;
    components.minute = 0;
    return [gregorian dateFromComponents:components];
}
@end
