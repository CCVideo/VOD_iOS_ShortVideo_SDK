#import "DWUploadTableViewCell.h"



@interface DWUploadTableViewCell ()

@end

@implementation DWUploadTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(void)createView
{
    // 视频缩略图
    self.thumbnailView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 18, 80, 60)];
    [self addSubview:self.thumbnailView];
    
    // 视频标题
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 18, 130, 30)];
    [self.titleLabel setNumberOfLines:1];
    self.titleLabel.font = [UIFont systemFontOfSize:12];
    [self addSubview:self.titleLabel];
    
    // 文件大小进度
    self.progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 53, 130, 20)];
    [self.progressLabel setNumberOfLines:1];
    [self.progressLabel setFont:[UIFont systemFontOfSize:10]];
    [self addSubview:self.progressLabel];
    
    // 进度条宽度
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(110, 78, 130, 10)];
    [self.progressView setProgressViewStyle:UIProgressViewStyleDefault];
    [self addSubview:self.progressView];
    
    //上传按钮
    self.statusButton = [DWImageTitleButton buttonWithType:UIButtonTypeCustom];
    [self.statusButton setFrame:CGRectMake(254, 32, 40, 40)];
    self.statusButton.adjustsImageWhenHighlighted = YES;
    self.statusButton.showsTouchWhenHighlighted =YES;
    [self.statusButton setUserInteractionEnabled:NO];
    [self.statusButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.statusButton.titleLabel.font = [UIFont systemFontOfSize:10];
    [self addSubview:self.statusButton];
    
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

-(void)setupCell:(DWuploadModel *)model
{
    
    // 视频缩略图
    UIImage *image = [DWShortTool dw_getThumbnailImage:model.videoPath time:0];
    [self.thumbnailView setImage:image];
    
    // 视频标题
    [self.titleLabel setText:[model videoTitle]];
    
    // 文件大小进度
    float uploadedSizeMB = [model videoUploadedSize]/1024.0/1024.0;
    
    [self.progressLabel setText:[NSString stringWithFormat:@"%0.1fM/%0.1fM", uploadedSizeMB,model.videoFileSize]];
    [self.progressLabel setNumberOfLines:1];
    
    // 进度条宽度
    [self.progressView setProgress:[model videoUploadProgress]];
    
    if (model.videoUploadStatus ==DWUploadStatusFinish) {
        
          [self.statusButton setTitle:@"完成" forState:UIControlStateNormal];
          [self.progressLabel setText:[NSString stringWithFormat:@"%0.1fM/%0.1fM",model.videoFileSize,model.videoFileSize]];
    }
   
    
}

- (void)updateCellProgressWithProgress:(float)progress andUploadedSize:(NSInteger)uploadedSize fileSize:(NSInteger)fileSize
{
    [self.progressView setProgress:progress];
    
    float uploadedSizeMB = uploadedSize/1024.0/1024.0;
    float fileSizeMB = fileSize/1024.0/1024.0;
    [self.progressLabel setText:[NSString stringWithFormat:@"%0.1fM/%0.1fM", uploadedSizeMB, fileSizeMB]];
}

- (void)updateCellProgress:(DWuploadModel *)model
{
    [self.progressView setProgress:[model videoUploadProgress]];
    
    float uploadedSizeMB = [model videoUploadedSize]/1024.0/1024.0;
    
    [self.progressLabel setText:[NSString stringWithFormat:@"%0.1fM/%0.1fM", uploadedSizeMB,model.videoFileSize]];
}

//完成
- (void)updateUploadStatus:(DWuploadModel *)model
{
    
    [self.statusButton setTitle:@"完成" forState:UIControlStateNormal];
   
    
}

- (BOOL)isDisableStatusButtonUserInteraction:(DWuploadModel *)model
{
    BOOL disable = NO;
    
    switch (model.videoUploadStatus) {
        case DWUploadStatusLoadLocalFileInvalid:
            disable = YES;
            break;
            
        case DWUploadStatusFinish:
            disable = YES;
            break;
            
        default:
            break;
    }
    
    return disable;
}


@end
