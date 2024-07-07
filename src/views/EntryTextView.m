#import "EntryTextView.h"

@interface EntryTextView ()
@property(nonatomic, retain) NSArray* tags;
@end

@implementation EntryTextView

- (NSArray<NSString*>*)completionsForPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger*)index {
    *index = -1;  // Do not preselect any tags
    return self.tags;
}

- (NSRange)rangeForUserCompletion {
    return [self selectedRange];
}

- (void)setTagCompletions:(NSArray*)tags {
    self.tags = tags;
}

- (void)dealloc {
    self.tags = nil;
    [super dealloc];
}

@end
