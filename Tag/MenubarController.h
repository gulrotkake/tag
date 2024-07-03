#define STATUS_ITEM_VIEW_WIDTH 24.0

#pragma mark -

@class StatusItemView;

@interface MenubarController : NSObject {
}

@property(nonatomic) BOOL hasActiveIcon;
@property(nonatomic, retain) NSStatusItem* statusItem;
@property(nonatomic, retain) StatusItemView* statusItemView;

- (void)setError:(NSString*)error;
- (void)setStatus:(BOOL)working;
- (void)startAnimation;
- (void)stopAnimation;

@end
