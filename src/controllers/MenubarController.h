#define STATUS_ITEM_VIEW_WIDTH 24.0

#pragma mark -

@interface MenubarController : NSObject {
}

@property(nonatomic) BOOL hasActiveIcon;
@property(nonatomic, retain) NSStatusItem* statusItem;

- (void)setError:(NSString*)error;
- (void)setStatus:(BOOL)working;

@end
