//
//  DWVideoTrimmerView.m
//  ShortVideoDemo
//
//  Created by zwl on 2019/10/23.
//  Copyright © 2019 Myself. All rights reserved.
//

#import "DWVideoTrimmerView.h"
#import "ICGVideoTrimmerView.h"

@interface DWVideoTrimmerView ()<ICGVideoTrimmerDelegate>

@property(nonatomic,assign)CGFloat notchBottom;
@property(nonatomic,strong)UIView * maskView;
@property(nonatomic,strong)UIView * videoTrimmerBgView;
@property(nonatomic,strong)ICGVideoTrimmerView * videoTrimmerView;
@property(nonatomic,assign)CMTime start;
@property(nonatomic,assign)CMTime duration;

@end

@implementation DWVideoTrimmerView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.hidden = YES;
        self.start = kCMTimeZero;
        self.duration = kCMTimeZero;
        
        self.maskView = [DWControl initViewWithFrame:CGRectZero BackgroundColor:[UIColor clearColor] Tag:0 AndAlpha:1];
        [self addSubview:self.maskView];
        [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
        [self.maskView addGestureRecognizer:tap];
        
        [self initVideoTrimmerView];
    }
    return self;
}

-(void)setVideoURL:(NSURL *)videoURL
{
    _videoURL = videoURL;
    
    AVAsset * asset = [AVURLAsset assetWithURL:self.videoURL];
    [self.videoTrimmerView setAsset:asset];
    
    [self.videoTrimmerView resetSubviews];

}

#pragma mark - action
-(void)dismiss
{
    self.hidden = YES;
    
    [self.delegate DWVideoTrimmerViewDismiss:self];
}

-(void)closeButtonAction
{
    [self dismiss];
}

-(void)sureButtonAction
{
    self.hidden = YES;

    [self.delegate DWVideoTrimmerView:self SureActionWithStart:self.start Duration:self.duration];
}

#pragma mark - ICGVideoTrimmerDelegate
- (void)trimmerView:(nonnull ICGVideoTrimmerView *)trimmerView didChangeLeftPosition:(CGFloat)startTime rightPosition:(CGFloat)endTime
{
    self.start = CMTimeMake(startTime * trimmerView.asset.duration.timescale, trimmerView.asset.duration.timescale);
    self.duration = CMTimeMake((endTime - startTime) * trimmerView.asset.duration.timescale, trimmerView.asset.duration.timescale);
}

-(void)initVideoTrimmerView
{
    //时间裁剪
    self.videoTrimmerBgView = [DWControl initViewWithFrame:CGRectZero BackgroundColor:[UIColor colorWithWhite:0 alpha:0.8] Tag:0 AndAlpha:1];
    [self addSubview:self.videoTrimmerBgView];
    [self.videoTrimmerBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(@0);
        make.bottom.equalTo(@0);
        make.height.equalTo(@(170 + self.notchBottom));
    }];
    
    UIButton * closeButton = [DWControl initButtonWithFrame:CGRectMake(15, 8, 24, 24) ButtonType:UIButtonTypeCustom Title:nil Image:@"icon_edit_close.png" Target:self Action:@selector(closeButtonAction) AndTag:0];
    [self.videoTrimmerBgView addSubview:closeButton];
    
    UIButton * sureButton = [DWControl initButtonWithFrame:CGRectMake(ScreenWidth - 15 - 24, 8, 24, 24) ButtonType:UIButtonTypeCustom Title:nil Image:@"icon_edit_sure.png" Target:self Action:@selector(sureButtonAction) AndTag:0];
    [self.videoTrimmerBgView addSubview:sureButton];
    
    self.videoTrimmerView = [[ICGVideoTrimmerView alloc]init];
    self.videoTrimmerView.frame = CGRectMake(0, CGRectGetMaxY(closeButton.frame) + 8, ScreenWidth, 170 - (CGRectGetMaxY(closeButton.frame) + 8));
    [self.videoTrimmerView setThemeColor:[UIColor colorWithRed:255/255.0 green:149/255.0 blue:32/255.0 alpha:1.0]];
    [self.videoTrimmerView setShowsRulerView:YES];
    [self.videoTrimmerView setRulerLabelInterval:10];
    [self.videoTrimmerView setDelegate:self];
    self.videoTrimmerView.minLength = 2;
    [self.videoTrimmerBgView addSubview:self.videoTrimmerView];
}

-(CGFloat)notchBottom
{
    if (@available(iOS 11.0, *)) {
        return [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0 ? 34 : 0;
    }
    return 0;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
