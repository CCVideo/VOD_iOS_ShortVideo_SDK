#import <UIKit/UIKit.h>


@interface DWUploadInfoSetupViewController : UIViewController

@property (strong, nonatomic)NSString *videoTitle;
@property (strong, nonatomic)NSString *videoTag;
@property (strong, nonatomic)NSString *videoDescription;
@property (assign, nonatomic)BOOL isCancel;

@property (nonatomic,assign)NSInteger selectIndex;

@end
