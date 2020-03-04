//
//  DWShortImagePickerViewController.m
//  ShortVideoDemo
//
//  Created by zwl on 2019/12/26.
//  Copyright © 2019 Myself. All rights reserved.
//

#import "DWShortImagePickerViewController.h"
#import "RTImagePickerViewController.h"
#import "DWShortVideoCropViewController.h"
#import "DWShortPictureCompositeViewController.h"

@interface DWShortImagePickerViewController ()

@property(nonatomic,assign)CGFloat notchTop;

@property(nonatomic,strong)UIView * lineView;

@property(nonatomic,assign)CGFloat index;
@property(nonatomic,strong)RTImagePickerViewController * videoPickerVC;
@property(nonatomic,strong)RTImagePickerViewController * imagePickerVC;

@end

@implementation DWShortImagePickerViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.index = 0;
    
    [self initUI];
    
    [self.view addSubview:self.imagePickerVC.view];
    [self.view addSubview:self.videoPickerVC.view];
    
}

-(void)dealloc
{

}

-(void)presentVideoEditVCWithUrl:(NSURL *)videoURL
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    path = [path stringByAppendingPathComponent:SHORTVIDEO];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    
    NSString * outPath = [[path stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@".MOV"];
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    hud.label.text = @"处理中，请稍后";
    
    [DWShortTool dw_compressionAndExportVideo:videoURL.absoluteString
                                  withOutPath:outPath
                               outputFileType:AVFileTypeQuickTimeMovie
                                   presetName:AVAssetExportPresetHighestQuality
                                  didComplete:^(NSError *error, NSURL *compressionFileURL) {
        
        [hud hideAnimated:YES];
        
        if (error) {
            [@"处理失败，请重选选择视频" showAlert];
            return;
        }
        
        DWShortVideoCropViewController * shortCropVC = [[DWShortVideoCropViewController alloc]init];
        shortCropVC.videoURL = compressionFileURL;
        [self presentViewController:shortCropVC animated:YES completion:nil];
        
    }];
}

-(BOOL)isVerifyVideoWithUrl:(NSURL *)videoURL
{
    //验证视频是否合法、
    //小于3分钟，大小小于100MB的视频
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSDictionary * fileAttr = [fileManager attributesOfItemAtPath:videoURL.absoluteString error:nil];
    NSInteger fileSize = (NSInteger)[[fileAttr objectForKey:NSFileSize] longLongValue];
    if (fileSize > 100 * 1024 * 1024) {
        return NO;
    }
    
    AVAsset * asset = [AVAsset assetWithURL:videoURL];
    CGFloat duration = asset.duration.value / asset.duration.timescale;
    if (duration > 180) {
        return NO;
    }
    
    return YES;
}


#pragma mark - action
-(void)leftButtonAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)nextButtonAction
{
    if (self.index == 0) {
        
        PHImageManager * imageManager = [PHImageManager defaultManager];
        //        NSMutableArray * videos = [NSMutableArray array];
        
        PHVideoRequestOptions * options = [PHVideoRequestOptions new];
        [options setDeliveryMode:PHVideoRequestOptionsDeliveryModeHighQualityFormat];
        
        [self.videoPickerVC.selectedAssets enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            PHAsset * asset = (PHAsset *)obj;
            
            [imageManager requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                
                //                [videos addObject:((AVURLAsset *)asset).URL.absoluteString];
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSURL * videoURL = ((AVURLAsset *)asset).URL;
                    
                    if (![self isVerifyVideoWithUrl:videoURL]) {
                        
                        [@"视频不符合规范，请重新选择" showAlert];
                        return;
                    }
                    
                    [self presentVideoEditVCWithUrl:videoURL];
                });
                
            }];
        }];
        
        
        
    }else{
//        NSLog(@"%@",self.imagePickerVC.selectedAssets);

        if (self.imagePickerVC.selectedAssets.count < 3) {
            [@"图片数量不能小于3张" showAlert];
            return;
        }
        
        PHImageManager * imageManager = [PHImageManager defaultManager];
        NSMutableArray * images = [NSMutableArray array];
        
        CGSize targetSize = CGSizeMake(ScreenWidth, ScreenHeight);
        
        PHImageRequestOptions * options = [PHImageRequestOptions new];
        [options setDeliveryMode:PHImageRequestOptionsDeliveryModeHighQualityFormat];
        
        __block int imageCount = 0;
        
        [self.imagePickerVC.chooseAssets enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            PHAsset * asset = (PHAsset *)obj;
            [images addObject:[NSMutableDictionary dictionary]];
            
            [imageManager requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                
                NSDictionary * imageDict = [images objectAtIndex:idx];
                [imageDict setValue:result forKey:@"image"];
                imageCount++;
                
                if (imageCount == self.imagePickerVC.selectedAssets.count) {
                    
                    NSMutableArray * imagesArray = [NSMutableArray array];
                    for (NSDictionary * image in images) {
                        [imagesArray addObject:[image objectForKey:@"image"]];
                    }
                    
                    DWShortPictureCompositeViewController * pictureCompositeVC = [[DWShortPictureCompositeViewController alloc] init];
                    pictureCompositeVC.imagesArray = imagesArray;
                    [self presentViewController:pictureCompositeVC animated:YES completion:nil];
                }
            }];
        }];

    }

}

-(void)typeButtonAction:(UIButton *)button
{
    if (button.selected) {
        return;
    }
    
    button.selected = !button.selected;
    
    if (button.tag == 100) {

        [self transitionFromViewController:self.imagePickerVC toViewController:self.videoPickerVC duration:1 options:UIViewAnimationOptionTransitionNone animations:nil completion:nil];
    }else{
        [self transitionFromViewController:self.videoPickerVC toViewController:self.imagePickerVC duration:1 options:UIViewAnimationOptionTransitionNone animations:nil completion:nil];
    }
    
    UIButton * preButton = (UIButton *)[self.view viewWithTag:button.tag == 100 ? 101 : 100];
    preButton.selected = NO;
    
    [self.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(self.lineView.frame.size.width));
        make.height.equalTo(@(self.lineView.frame.size.height));
        make.centerX.equalTo(button);
        make.bottom.equalTo(@0);
    }];
    
    self.index = button.tag - 100;
}

#pragma mark - init
-(void)initUI
{
    self.view.backgroundColor = [UIColor blackColor];
    
    UIButton * leftButton = [DWControl initButtonWithFrame:CGRectZero ButtonType:UIButtonTypeCustom Title:nil Image:@"icon_back.png" Target:self Action:@selector(leftButtonAction) AndTag:0];
    [self.view addSubview:leftButton];
    [leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@12);
        make.top.equalTo(@(self.notchTop + 15));
        make.width.and.height.equalTo(@30);
    }];
        
    UIButton * nextButton = [DWControl initButtonWithFrame:CGRectZero ButtonType:UIButtonTypeCustom Title:@"完成" Image:nil Target:self Action:@selector(nextButtonAction) AndTag:0];
    [nextButton setBackgroundImage:[[UIColor colorWithRed:255/255.0 green:149/255.0 blue:32/255.0 alpha:1.0] createImage] forState:UIControlStateNormal];
    [nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    nextButton.titleLabel.font = [UIFont systemFontOfSize:13];
    nextButton.layer.masksToBounds = YES;
    nextButton.layer.cornerRadius = 30 / 2.0;
    [self.view addSubview:nextButton];
    [nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@(-12));
        make.centerY.equalTo(leftButton);
        make.height.equalTo(@30);
        make.width.equalTo(@59);
    }];
    
    UIView * typeBgView = [DWControl initViewWithFrame:CGRectZero BackgroundColor:[UIColor clearColor] Tag:0 AndAlpha:1];
    [self.view addSubview:typeBgView];
    [typeBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(@0);
        make.top.equalTo(leftButton.mas_bottom);
        make.height.equalTo(@40);
    }];
    
    NSArray * titles = @[@"视频",@"图片"];
    for (int i = 0; i < titles.count; i++) {
        UIButton * button = [DWControl initButtonWithFrame:CGRectZero ButtonType:UIButtonTypeCustom Title:[titles objectAtIndex:i] Image:nil Target:self Action:@selector(typeButtonAction:) AndTag:100 + i];
        [button setTitleColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.5] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1] forState:UIControlStateSelected];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [typeBgView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(i * (ScreenWidth / 2.0)));
            make.width.equalTo(@(ScreenWidth / 2.0));
            make.top.equalTo(@0);
            make.height.equalTo(typeBgView);
        }];
        
        if (i == 0) {
            button.selected = YES;
            
            [typeBgView addSubview:self.lineView];
            [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@(self.lineView.frame.size.width));
                make.height.equalTo(@(self.lineView.frame.size.height));
                make.centerX.equalTo(button);
                make.bottom.equalTo(@0);
            }];
        }
    }
}

-(CGFloat)notchTop
{
    if (@available(iOS 11.0, *)) {
        return [[UIApplication sharedApplication] delegate].window.safeAreaInsets.top > 0 ? 22 : 0;
    }
    return 0;
}

-(UIView *)lineView
{
    if (!_lineView) {
        _lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 50, 1.5)];
        _lineView.backgroundColor = [UIColor colorWithRed:255/255.0 green:149/255.0 blue:32/255.0 alpha:1.0];
    }
    return _lineView;
}

-(RTImagePickerViewController *)videoPickerVC
{
    if (!_videoPickerVC) {
        _videoPickerVC = [[RTImagePickerViewController alloc]init];
        if (@available(iOS 13, *)) {
            _videoPickerVC.modalPresentationStyle = UIModalPresentationFullScreen;
        }
        //_videoPickerVC.delegate = self;
        _videoPickerVC.mediaType = RTImagePickerMediaTypeVideo;
        _videoPickerVC.allowsMultipleSelection = YES;
        _videoPickerVC.showsNumberOfSelectedAssets = YES;
        _videoPickerVC.maximumNumberOfSelection = 1;
        _videoPickerVC.numberOfColumnsInPortrait = 4;
        [self addChildViewController:_videoPickerVC];
        _videoPickerVC.view.frame = CGRectMake(0, self.notchTop + 15 + 30 + 40, ScreenWidth, ScreenHeight - (self.notchTop + 15 + 30 + 40));
    }
    return _videoPickerVC;
}

-(RTImagePickerViewController *)imagePickerVC
{
    if (!_imagePickerVC) {
        _imagePickerVC = [[RTImagePickerViewController alloc]init];
        if (@available(iOS 13, *)) {
            _imagePickerVC.modalPresentationStyle = UIModalPresentationFullScreen;
        }
        //_imagePickerVC.delegate = self;
        _imagePickerVC.mediaType = RTImagePickerMediaTypeImage;
        _imagePickerVC.allowsMultipleSelection = YES;
        _imagePickerVC.showsNumberOfSelectedAssets = YES;
        _imagePickerVC.maximumNumberOfSelection = 30;
        _imagePickerVC.numberOfColumnsInPortrait = 4;
        [self addChildViewController:_imagePickerVC];
        _imagePickerVC.view.frame = CGRectMake(0, self.notchTop + 15 + 30 + 40, ScreenWidth, ScreenHeight - (self.notchTop + 15 + 30 + 40));
    }
    return _imagePickerVC;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
