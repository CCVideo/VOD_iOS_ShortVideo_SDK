//
//  DWEditCropView.m
//  ShortVideoDemo
//
//  Created by zwl on 2019/9/20.
//  Copyright © 2019 Myself. All rights reserved.
//

#import "DWEditCropView.h"
#import "ICGVideoTrimmerView.h"
#import "DWImageView.h"

@interface DWEditCropView () <ICGVideoTrimmerDelegate>

@property(nonatomic,assign)CGFloat notchTop;
@property(nonatomic,assign)CGFloat notchBottom;

@property(nonatomic,strong)UIView * cropBgView;
@property(nonatomic,strong)UIButton * speedButton;
@property(nonatomic,strong)UIButton * scaleButton;
@property(nonatomic,strong)ICGVideoTrimmerView * videoTrimmerView;

@property(nonatomic,strong)DWImageView * scaleView;//缩放效果图
@property(nonatomic,strong)NSArray * scaleArray;
@property(nonatomic,strong)UIView * scaleChooseBgView;//缩放选择view
@property(nonatomic,assign)NSInteger scaleIndex;

@property(nonatomic,strong)UIView * speedChooseBgView;//倍速选择view
@property(nonatomic,assign)NSInteger speedIndex;
@property(nonatomic,strong)NSArray * speedArray;

@end

@implementation DWEditCropView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.start = kCMTimeZero;
        self.duration = kCMTimeZero;
        
        self.scaleIndex = 0;
        self.speedIndex = 2;
        
        [self initTopView];
        
        [self initCropView];
    }
    return self;
}

-(void)setVideoURL:(NSURL *)videoURL
{
    _videoURL = videoURL;
    
    AVAsset * asset = [AVURLAsset assetWithURL:videoURL];
    
    self.videoTrimmerView.maxLength = asset.duration.value / asset.duration.timescale;
    
    [self.videoTrimmerView setAsset:asset];
    
    [self.videoTrimmerView resetSubviews];
}

-(void)seekToTime:(CGFloat)second
{
    [self.videoTrimmerView seekToTime:second];
}

-(CGFloat)speed
{
    return [[self.speedArray objectAtIndex:self.speedIndex] floatValue];
}

-(CGRect)scaleFrame
{
    CGRect scaleFrame = [self.scaleView currentCroppedRect];
    
    CGRect frame;
    if (self.scaleIndex == 0) {
      frame = CGRectZero;
    }else{
      frame = CGRectMake(scaleFrame.origin.x / self.videoScale, scaleFrame.origin.y / self.videoScale, scaleFrame.size.width / self.videoScale, scaleFrame.size.height / self.videoScale);
    }
    return frame;
}

#pragma mark - action
-(void)leftButtonAction
{
    [self.delegate DWEditCropViewLeftButtonAction];
}

-(void)nextButtonAction
{
    [self.delegate DWEditCropViewNextButtonAction];
}

-(void)scaleButtonAction
{
    if (!self.speedChooseBgView.hidden) {
        self.speedButton.selected = NO;
        self.speedChooseBgView.hidden = YES;
    }
    
    self.scaleButton.selected = !self.scaleButton.selected;
    
    self.scaleChooseBgView.hidden = !self.scaleButton.selected;
    
    if (self.scaleIndex == 0) {
        self.scaleView.hidden = YES;
    }else{
        self.scaleView.hidden = self.scaleChooseBgView.hidden;
    }
    
}

-(void)speedButtonAction:(UIButton *)button
{
    if (!self.scaleChooseBgView.hidden) {
        self.scaleButton.selected = NO;
        self.scaleChooseBgView.hidden = YES;
        self.scaleView.hidden = YES;
    }
    
    button.selected = !button.selected;
    
    self.speedChooseBgView.hidden = !button.selected;
}

-(void)scaleChooseAction:(UIButton *)button
{
    // 100 + i
    if (button.selected) {
        return;
    }
    
    UIButton * preButton = (UIButton *)[self.scaleChooseBgView viewWithTag:100 + self.scaleIndex];
    preButton.selected = NO;
    
    button.selected = YES;
    
    self.scaleIndex = button.tag - 100;
    
    NSString * imageName = nil;
    
    if (self.scaleIndex == 0) {
        self.scaleView.hidden = YES;
        imageName = @"icon_edit_original";
    }else if (self.scaleIndex == 1) {
        self.scaleView.hidden = NO;
        imageName = @"icon_edit_1_1";
    }else if (self.scaleIndex == 2){
        self.scaleView.hidden = NO;
        imageName = @"icon_edit_4_3";
    }else if (self.scaleIndex == 3){
        self.scaleView.hidden = NO;
        imageName = @"icon_edit_16_9";
    }else if (self.scaleIndex == 4){
        self.scaleView.hidden = NO;
        imageName = @"icon_edit_9_16";
    }
    [self.scaleButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",imageName]] forState:UIControlStateNormal];
    [self.scaleButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_select.png",imageName]] forState:UIControlStateSelected];

    CGFloat scale = [[self.scaleArray objectAtIndex:self.scaleIndex] floatValue];
    _scaleView.cropAspectRatio = scale;
}

-(void)speedChooseAction:(UIButton *)button
{
    // 200 + i
    if (button.selected) {
        return;
    }
    
    UIButton * preButton = (UIButton *)[self.speedChooseBgView viewWithTag:200 + self.speedIndex];
    preButton.selected = NO;
    
    button.selected = YES;
    
    self.speedIndex = button.tag - 200;
    
    [self.delegate DWEditCropViewDidChangeSpeed:[[self.speedArray objectAtIndex:self.speedIndex] floatValue]];
}

#pragma mark - ICGVideoTrimmerDelegate
- (void)trimmerView:(nonnull ICGVideoTrimmerView *)trimmerView didChangeLeftPosition:(CGFloat)startTime rightPosition:(CGFloat)endTime
{
    self.start = CMTimeMake(startTime * trimmerView.asset.duration.timescale, trimmerView.asset.duration.timescale);
    self.duration = CMTimeMake((endTime - startTime) * trimmerView.asset.duration.timescale, trimmerView.asset.duration.timescale);
}

#pragma mark - init
-(void)initTopView
{
    UIButton * leftButton = [DWControl initButtonWithFrame:CGRectZero ButtonType:UIButtonTypeCustom Title:nil Image:@"icon_back.png" Target:self Action:@selector(leftButtonAction) AndTag:0];
    [self addSubview:leftButton];
    [leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@12);
        make.top.equalTo(@(self.notchTop + 15));
        make.width.and.height.equalTo(@30);
    }];

    UIButton * nextButton = [DWControl initButtonWithFrame:CGRectZero ButtonType:UIButtonTypeCustom Title:@"下一步" Image:nil Target:self Action:@selector(nextButtonAction) AndTag:0];
    [nextButton setBackgroundImage:[[UIColor colorWithRed:255/255.0 green:149/255.0 blue:32/255.0 alpha:1.0] createImage] forState:UIControlStateNormal];
    [nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    nextButton.titleLabel.font = [UIFont systemFontOfSize:13];
    nextButton.layer.masksToBounds = YES;
    nextButton.layer.cornerRadius = 30 / 2.0;
    [self addSubview:nextButton];
    [nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@(-12));
        make.centerY.equalTo(leftButton);
        make.height.equalTo(@30);
        make.width.equalTo(@59);
    }];
}

-(void)initCropView
{
    //时间裁剪
    self.cropBgView = [DWControl initViewWithFrame:CGRectZero BackgroundColor:[UIColor colorWithWhite:0 alpha:0.8] Tag:0 AndAlpha:1];
    [self addSubview:self.cropBgView];
    [self.cropBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(@0);
        make.bottom.equalTo(@0);
        make.height.equalTo(@(170 + self.notchBottom));
    }];
    
    self.speedButton = [DWControl initButtonWithFrame:CGRectMake(ScreenWidth - 15 - 24, 8, 24, 24) ButtonType:UIButtonTypeCustom Title:nil Image:nil Target:self Action:@selector(speedButtonAction:) AndTag:0];
    [self.speedButton setBackgroundImage:[UIImage imageNamed:@"icon_edit_speed.png"] forState:UIControlStateNormal];
    [self.speedButton setBackgroundImage:[UIImage imageNamed:@"icon_edit_speed_select.png"] forState:UIControlStateSelected];
    [self.cropBgView addSubview:self.speedButton];
    
    self.scaleButton = [DWControl initButtonWithFrame:CGRectMake(ScreenWidth - 15 - 24 - (24 + 10) * 1, 8, 24, 24) ButtonType:UIButtonTypeCustom Title:nil Image:nil Target:self Action:@selector(scaleButtonAction) AndTag:0];
    [self.scaleButton setBackgroundImage:[UIImage imageNamed:@"icon_edit_original.png"] forState:UIControlStateNormal];
    [self.scaleButton setBackgroundImage:[UIImage imageNamed:@"icon_edit_original_select.png"] forState:UIControlStateSelected];
    [self.cropBgView addSubview:self.scaleButton];
    
    self.videoTrimmerView = [[ICGVideoTrimmerView alloc]init];
    self.videoTrimmerView.frame = CGRectMake(0, CGRectGetMaxY(self.speedButton.frame) + 8, ScreenWidth, 170 - (CGRectGetMaxY(self.speedButton.frame) + 8));
    [self.videoTrimmerView setThemeColor:[UIColor colorWithRed:255/255.0 green:149/255.0 blue:32/255.0 alpha:1.0]];
    [self.videoTrimmerView setShowsRulerView:YES];
    [self.videoTrimmerView setRulerLabelInterval:10];
    [self.videoTrimmerView setDelegate:self];
    self.videoTrimmerView.minLength = 2;
    [self.cropBgView addSubview:self.videoTrimmerView];
}

-(UIView *)scaleChooseBgView
{
    if (!_scaleChooseBgView) {
        _scaleChooseBgView = [DWControl initViewWithFrame:CGRectZero BackgroundColor:[UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:0.8] Tag:0 AndAlpha:1];
        _scaleChooseBgView.layer.masksToBounds = YES;
        _scaleChooseBgView.layer.cornerRadius = 15;
        _scaleChooseBgView.hidden = YES;
        [self addSubview:_scaleChooseBgView];
        
        CGFloat width = 300;
        CGFloat height = _scaleChooseBgView.layer.cornerRadius * 2;
        [_scaleChooseBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.bottom.equalTo(self.cropBgView.mas_top).offset(-4);
            make.width.equalTo(@(width));
            make.height.equalTo(@(height));
        }];
        
        NSArray * titles = @[@"原比例",@"1:1",@"4:3",@"16:9",@"9:16"];
        for (int i = 0; i < titles.count; i++) {
            UIButton * button = [DWControl initButtonWithFrame:CGRectZero ButtonType:UIButtonTypeCustom Title:[titles objectAtIndex:i] Image:nil Target:self Action:@selector(scaleChooseAction:) AndTag:100 + i];
            button.titleLabel.font = [UIFont systemFontOfSize:14];
            button.titleLabel.textAlignment = NSTextAlignmentCenter;
            [button setBackgroundImage:[[UIColor clearColor] createImage] forState:UIControlStateNormal];
            [button setBackgroundImage:[[UIColor colorWithRed:255/255.0 green:149/255.0 blue:32/255.0 alpha:1.0] createImage] forState:UIControlStateSelected];
            button.layer.masksToBounds = YES;
            button.layer.cornerRadius = _scaleChooseBgView.layer.cornerRadius;
            [_scaleChooseBgView addSubview:button];
            
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.and.height.equalTo(_scaleChooseBgView);
                make.left.equalTo(@((width / 5) * i));
                make.width.equalTo(@((width / 5)));
            }];
            
            if (i == 0) {
                button.selected = YES;
            }
        
        }
    }
    return _scaleChooseBgView;
}

-(UIView *)speedChooseBgView
{
    if (!_speedChooseBgView) {
        _speedChooseBgView = [DWControl initViewWithFrame:CGRectZero BackgroundColor:[UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:0.8] Tag:0 AndAlpha:1];
        _speedChooseBgView.layer.masksToBounds = YES;
        _speedChooseBgView.layer.cornerRadius = 15;
        _speedChooseBgView.hidden = YES;
        [self addSubview:_speedChooseBgView];
        
        CGFloat width = 300;
        CGFloat height = _speedChooseBgView.layer.cornerRadius * 2;
        [_speedChooseBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.bottom.equalTo(self.cropBgView.mas_top).offset(-4);
            make.width.equalTo(@(width));
            make.height.equalTo(@(height));
        }];
        
    
        NSArray * titles = @[@"极慢",@"慢",@"标准",@"快",@"极快"];
        for (int i = 0; i < titles.count; i++) {
            UIButton * button = [DWControl initButtonWithFrame:CGRectZero ButtonType:UIButtonTypeCustom Title:[titles objectAtIndex:i] Image:nil Target:self Action:@selector(speedChooseAction:) AndTag:200 + i];
            button.titleLabel.font = [UIFont systemFontOfSize:14];
            button.titleLabel.textAlignment = NSTextAlignmentCenter;
            [button setBackgroundImage:[[UIColor clearColor] createImage] forState:UIControlStateNormal];
            [button setBackgroundImage:[[UIColor colorWithRed:255/255.0 green:149/255.0 blue:32/255.0 alpha:1.0] createImage] forState:UIControlStateSelected];
            button.layer.masksToBounds = YES;
            button.layer.cornerRadius = _speedChooseBgView.layer.cornerRadius;
            [_speedChooseBgView addSubview:button];
            
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.and.height.equalTo(_speedChooseBgView);
                make.left.equalTo(@((width / 5) * i));
                make.width.equalTo(@((width / 5)));
            }];
            
            if (i == 2) {
                
                button.selected = YES;
            }
        }
    }
        
    return _speedChooseBgView;
}

-(UIView *)scaleView
{
    if (!_scaleView) {
        CGRect frame = CGRectMake((ScreenWidth - ScreenWidth * self.videoScale) / 2.0, 0, ScreenWidth * self.videoScale, ScreenHeight * self.videoScale);
        _scaleView = [[DWImageView alloc]initWithFrame:frame];
        _scaleView.toCropImage = [[UIColor clearColor] createImageWithSize:frame.size];
        _scaleView.showMidLines = YES;
        _scaleView.needScaleCrop = YES;
        _scaleView.showCrossLines = YES;
        _scaleView.cornerBorderInImage = NO;
        _scaleView.cropAreaCornerWidth = 44;
        _scaleView.cropAreaCornerHeight = 44;
        _scaleView.minSpace = 30;
        _scaleView.cropAreaCornerLineColor = [UIColor whiteColor];
        _scaleView.cropAreaBorderLineColor = [UIColor whiteColor];
        _scaleView.cropAreaCornerLineWidth = 2;
        _scaleView.cropAreaBorderLineWidth = 2;
        _scaleView.cropAreaMidLineWidth = 20;
        _scaleView.cropAreaMidLineHeight = 6;
        _scaleView.cropAreaMidLineColor = [UIColor whiteColor];
        _scaleView.cropAreaCrossLineColor = [UIColor whiteColor];
        _scaleView.cropAreaCrossLineWidth = 1;
        _scaleView.initialScaleFactor = .8f;
        _scaleView.cropAspectRatio = [[self.scaleArray objectAtIndex:self.scaleIndex] floatValue];
        _scaleView.hidden = YES;
        [self insertSubview:_scaleView atIndex:0];
    }
    return _scaleView;
}

-(NSArray *)scaleArray
{
    if (!_scaleArray) {
        _scaleArray = @[@0,@(1),@(4/3.0),@(16/9.0),@(9/16.0)];
    }
    return _scaleArray;
}

-(NSArray *)speedArray
{
    if (!_speedArray) {
        _speedArray = @[@0.25,@0.5,@1.0,@1.5,@2.0];
    }
    return _speedArray;
}

-(CGFloat)notchTop
{
    if (@available(iOS 11.0, *)) {
        return [[UIApplication sharedApplication] delegate].window.safeAreaInsets.top > 0 ? 22 : 0;
    }
    return 0;
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
