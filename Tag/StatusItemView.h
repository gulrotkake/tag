@interface StatusItemView : NSView {
}

- (id)initWithStatusItem:(NSStatusItem*)statusItem;
- (void)activate;

@property(nonatomic, retain) NSStatusItem* statusItem;
@property(nonatomic, retain) NSImage* image;
@property(nonatomic, retain) NSImage* alternateImage;
@property(nonatomic, assign) BOOL isHighlighted;
@property(nonatomic, assign, readonly) NSRect globalRect;
@property(nonatomic, assign) SEL action;
@property(nonatomic, assign) id target;

@end
