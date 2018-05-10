#import <UIKit/UIKit.h>
#import "DWuploadModel.h"
#import "DWImageTitleButton.h"

@interface DWUploadTableViewCell : UITableViewCell

@property (strong, nonatomic)UIImageView *thumbnailView;

@property (strong, nonatomic)UILabel *progressLabel;
@property (strong, nonatomic)UILabel *titleLabel;
@property (strong,nonatomic)UIButton *statusButton;

@property (strong, nonatomic)UIProgressView *progressView;

@property (nonatomic,strong)DWuploadModel *model;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

-(void)setupCell:(DWuploadModel *)model;

- (void)updateCellProgress:(DWuploadModel *)model;

- (void)updateUploadStatus:(DWuploadModel *)model;

@end
