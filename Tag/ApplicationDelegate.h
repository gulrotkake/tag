#import "MenubarController.h"
#import "PanelController.h"

@interface ApplicationDelegate : NSObject <NSApplicationDelegate, PanelControllerDelegate>

@property (nonatomic, retain) MenubarController *menubarController;
@property (nonatomic, retain) PanelController *panelController;

- (IBAction)togglePanel:(id)sender;

@end
