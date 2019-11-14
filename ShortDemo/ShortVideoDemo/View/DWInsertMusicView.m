//
//  DWInsertMusicView.m
//  ShortVideoDemo
//
//  Created by zwl on 2019/9/20.
//  Copyright © 2019 Myself. All rights reserved.
//

#import "DWInsertMusicView.h"
#import <AVFoundation/AVFoundation.h>

@interface DWInsertMusicView ()

@property(nonatomic,assign)CGFloat notchTop;
@property(nonatomic,assign)CGFloat notchBottom;
@property(nonatomic,strong)UIView * maskView;
@property(nonatomic,strong)UIView * bgView;
@property(nonatomic,strong)AVAudioPlayer * player;

//音乐选择
@property(nonatomic,strong)UIView * audioPositionView;
@property(nonatomic,strong)DWMusicSpectrum * musicSpectrum;
@property(nonatomic,assign)CGFloat sliderPostion;
@property(nonatomic,assign)CMTime start;
@property(nonatomic,assign)CMTime duration;

//音量选择
@property(nonatomic,strong)UIView * audioMixView;
@property(nonatomic,strong)UILabel * originalLabel;
@property(nonatomic,strong)UILabel * insertLabel;
@property(nonatomic,strong)UISlider * originalSlider;
@property(nonatomic,strong)UISlider * insertSlider;

@end

@implementation DWInsertMusicView

-(instancetype)init
{
    if (self == [super init]) {
        
        self.start = kCMTimeZero;
        self.duration = kCMTimeZero;
        self.sliderPostion = 0;
        
        self.maskView = [DWControl initViewWithFrame:CGRectZero BackgroundColor:[UIColor clearColor] Tag:0 AndAlpha:1];
        [self addSubview:self.maskView];
        [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
        [self.maskView addGestureRecognizer:tap];
        
        [self initBgView];
        [self initAudioPositionView];
        [self initAudioMixView];
        
    }
    return self;
}

-(void)setAudioPath:(NSString *)audioPath
{
    _audioPath = audioPath;
    
    if (self.player) {
        [self.player stop];
    }
    
    if (!audioPath) {
        return;
    }
    
    self.player = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:audioPath] error:nil];
    [self.player setVolume:self.insertSlider.value / 100.0];
    [self.player prepareToPlay];
    [self.player play];
    
    [self.musicSpectrum setCurrentTime:@"00:00"];
    [self.musicSpectrum setTotalTime:[self formatSecondsToString:self.player.duration]];
    [self.musicSpectrum setPostion:0];
}

-(NSString *)formatSecondsToString:(NSInteger)seconds
{
    if (seconds < 0) {
        return @"00:00";
    }
    
    int m = (int)round(seconds / 60);
    int s = (int)round(seconds % 60);
    
    return [NSString stringWithFormat:@"%02d:%02d",m,s];
}

-(void)setPlayerCurrentTime:(CGFloat)postion
{
    [self.player pause];
    CGFloat currentTime = self.player.duration * postion;
    [self.player setCurrentTime:currentTime];
    [self.musicSpectrum setCurrentTime:[self formatSecondsToString:currentTime]];
    [self.player play];
    
    self.start = CMTimeMake(currentTime * 30, 30);
    self.duration = CMTimeMake((self.player.duration - currentTime) * 30, 30);
}

#pragma mark - action
-(void)dismiss
{
    self.hidden = YES;
    
    [self.delegate DWInsertMusicDismiss];
}

-(void)audioPlay
{
    if (!self.audioPath) {
        return;
    }
    
    [self.player play];
}

-(void)audioPause
{
    if (!self.audioPath) {
        return;
    }
    
    [self.player pause];
}

-(void)repeatPlay
{
    if (!self.audioPath) {
        return;
    }
    
    [self setPlayerCurrentTime:self.sliderPostion];
}

-(void)chooseButtonAction:(UIButton *)button
{
    // 100 + i
    if (button.selected) {
        return;
    }
    
    button.selected = NO;
    
    UIButton * anotherButton = (UIButton *)[self.bgView viewWithTag:button.tag == 100 ? 101 : 100];
    anotherButton.selected = NO;
    
    self.audioPositionView.hidden = button.tag == 100 ? NO : YES;
    self.audioMixView.hidden = button.tag == 100 ? YES : NO;
}

-(void)sureButtonAction
{
    self.hidden = YES;

    [self.delegate DWInsertMusicViewDidFinishWithAudioPath:self.audioPath OriginalVolume:self.originalSlider.value / 100.0 InsertVolume:self.insertSlider.value / 100.0 StartTime:self.start DurationTime:self.duration];
}

-(void)sliderValueChange:(UISlider *)slider
{
    if (slider.tag == 100) {
        self.originalLabel.text = [NSString stringWithFormat:@"%.0f",slider.value];
        
        [self.delegate DWInsertMusicOriginalVolumeValueChange:slider.value];
    }
    
    if (slider.tag == 101) {
        self.insertLabel.text = [NSString stringWithFormat:@"%.0f",slider.value];
        
        [self.player setVolume:slider.value / 100.0];
    }
}

#pragma mark - init
-(void)initBgView
{
    self.bgView = [DWControl initViewWithFrame:CGRectZero BackgroundColor:[UIColor colorWithWhite:0 alpha:0.8] Tag:0 AndAlpha:1];
    [self addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(@0);
        make.bottom.equalTo(@0);
        make.height.equalTo(@(170 + self.notchBottom));
    }];
    
    NSArray * titles = @[@"音乐",@"音量"];
    
    for (int i = 0; i < titles.count; i++) {
        UIButton * button = [DWControl initButtonWithFrame:CGRectZero ButtonType:UIButtonTypeCustom Title:[titles objectAtIndex:i] Image:nil Target:self Action:@selector(chooseButtonAction:) AndTag:100 + i];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [button setTitleColor:[UIColor colorWithWhite:1 alpha:0.6] forState:UIControlStateNormal];
        if (i == 0) {
            button.selected = YES;
        }
        [self.bgView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(54 * i));
            make.top.equalTo(@0);
            make.height.equalTo(@31);
            make.width.equalTo(@(54));
        }];
    }
    
    UIButton * sureButton = [DWControl initButtonWithFrame:CGRectMake(ScreenWidth - 15 - 24, 8, 24, 24) ButtonType:UIButtonTypeCustom Title:nil Image:@"icon_edit_sure.png" Target:self Action:@selector(sureButtonAction) AndTag:0];
    [self.bgView addSubview:sureButton];
}

-(void)initAudioPositionView
{
    self.audioPositionView = [DWControl initViewWithFrame:CGRectZero BackgroundColor:[UIColor clearColor] Tag:0 AndAlpha:1];
    [self.bgView addSubview:self.audioPositionView];
    [self.audioPositionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.bottom.equalTo(@(-self.notchBottom));
        make.width.equalTo(self);
        make.height.equalTo(@(170 - 40));
    }];
    
    self.musicSpectrum = [[DWMusicSpectrum alloc]initWithFrame:CGRectMake(0, 20, ScreenWidth, 90)];
    [self.audioPositionView addSubview:self.musicSpectrum];

    __weak typeof(self) weakSelf = self;
    //进度条拖拽回调
    self.musicSpectrum.valueChange = ^(CGFloat postion) {
        if (weakSelf.player.isPlaying) {
            [weakSelf setPlayerCurrentTime:postion];
            weakSelf.sliderPostion = postion;
        }
    };
}

-(void)initAudioMixView
{
    self.audioMixView = [DWControl initViewWithFrame:CGRectZero BackgroundColor:[UIColor clearColor] Tag:0 AndAlpha:1];
    self.audioMixView.hidden = YES;
    [self.bgView addSubview:self.audioMixView];
    [self.audioMixView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.bottom.equalTo(@(-self.notchBottom));
        make.width.equalTo(self);
        make.height.equalTo(@(170 - 40));
    }];
    
    NSArray * titles = @[@"原声",@"配乐"];
    CGFloat space = (130 - 50 * 2) / 3.0;
    for (int i = 0; i < titles.count; i++) {
        UIView * view = [DWControl initViewWithFrame:CGRectZero BackgroundColor:[UIColor clearColor] Tag:0 AndAlpha:1];
        [self.audioMixView addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@(space + (space + 50) * i));
            make.left.and.right.equalTo(@0);
            make.height.equalTo(@50);
        }];
        
        UILabel * bLabel = [DWControl initLabelWithFrame:CGRectZero Title:[titles objectAtIndex:i] TextColor:[UIColor colorWithWhite:1 alpha:0.7] TextAlignment:NSTextAlignmentCenter AndFont:[UIFont systemFontOfSize:13]];
        [view addSubview:bLabel];
        [bLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0);
            make.width.equalTo(@86);
            make.centerY.equalTo(view);
            make.height.equalTo(@13);
        }];
        
        UILabel * currentLabel = [DWControl initLabelWithFrame:CGRectZero Title:@"50" TextColor:[UIColor colorWithWhite:1 alpha:0.6] TextAlignment:NSTextAlignmentCenter AndFont:[UIFont systemFontOfSize:13]];
        [view addSubview:currentLabel];
        [currentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(bLabel.mas_right).offset(12);
            make.right.equalTo(@(-30));
            make.top.equalTo(@5);
            make.height.equalTo(@13);
        }];
        
        UISlider * slider = [[UISlider alloc]init];
        [slider setThumbImage:[UIImage imageNamed:@"icon_beauty_point.png"] forState:UIControlStateNormal];
        [slider setMinimumTrackTintColor:[UIColor colorWithRed:255/255.0 green:149/255.0 blue:32/255.0 alpha:1]];
        [slider setMaximumTrackTintColor:[UIColor colorWithWhite:1 alpha:0.3]];
        slider.maximumValue = 100;
        slider.minimumValue = 0;
        slider.value = 50;
        [slider addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];
        slider.tag = 100 + i;
        [view addSubview:slider];
        [slider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(currentLabel);
            make.bottom.equalTo(@(-5));
            make.top.equalTo(currentLabel.mas_bottom).offset(3);
        }];
        
        if (i == 0) {
            self.originalLabel = currentLabel;
            self.originalSlider = slider;
        }
        if (i == 1) {
            self.insertLabel = currentLabel;
            self.insertSlider = slider;
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

@interface DWMusicSpectrum ()

@property(nonatomic,strong)NSArray * heightArray;
@property(nonatomic,strong)NSMutableArray * layersArray;

@property(nonatomic,strong)UILabel * currentLabel;
@property(nonatomic,strong)UILabel * totalLabel;

@property(nonatomic,assign)CGFloat layerS;
@property(nonatomic,assign)CGFloat layerOriginX;
@property(nonatomic,assign)CGFloat layerW;
@property(nonatomic,assign)CGFloat layerH;

@property(nonatomic,strong)UIImageView * sliderImageView;

@end

@implementation DWMusicSpectrum

static int n = 30;

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self == [super initWithFrame:frame]) {
        
        self.layerS = 2;
        self.layerOriginX = 24 + self.totalLabel.frame.size.width + 10;
        
        self.layerW = ((frame.size.width - self.layerOriginX * 2) - self.layerS * (n + 1)) / n;
        self.layerH = frame.size.height * 0.7;
        
        [self addSubview:self.currentLabel];
        self.currentLabel.frame = CGRectMake(24, (self.layerH - self.currentLabel.frame.size.height) / 2.0, self.currentLabel.frame.size.width, self.currentLabel.frame.size.height);
        
        [self addSubview:self.totalLabel];
        self.totalLabel.frame = CGRectMake(frame.size.width - (24 + self.totalLabel.frame.size.width), self.currentLabel.frame.origin.y, self.totalLabel.frame.size.width, self.totalLabel.frame.size.height);
        
        
        for (int i = 0; i < n; i++) {
            
            CGFloat height = self.layerH * [[self.heightArray objectAtIndex:i] floatValue];
            
            CALayer * layer = [CALayer layer];
            layer.frame = CGRectMake(self.layerOriginX + self.layerS + (self.layerW + self.layerS) * i, (self.layerH - height) / 2.0, self.layerW, height);
            layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:149/255.0 blue:32/255.0 alpha:1.0].CGColor;
            layer.cornerRadius = self.layerW / 2;
            [self.layer addSublayer:layer];
            [self.layersArray addObject:layer];
        }
        
        self.sliderImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_edit_slider.png"]];
        self.sliderImageView.frame = CGRectMake(0, self.frame.size.height - 24, 60, 24);
        self.sliderImageView.userInteractionEnabled = YES;
        [self addSubview:self.sliderImageView];
        
        UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panAction:)];
        [self.sliderImageView addGestureRecognizer:pan];
        
        [self setPostion:0];
    }
    return self;
}

-(void)panAction:(UIPanGestureRecognizer *)pan
{
    CGPoint offset = [pan locationInView:self];
    
//    NSLog(@"%f",offset.x);
    
    if (offset.x < self.layerOriginX) {
        self.sliderImageView.center = CGPointMake(self.layerOriginX, self.sliderImageView.center.y);
    }else if (offset.x > self.frame.size.width - self.layerOriginX) {
        self.sliderImageView.center = CGPointMake(self.frame.size.width - self.layerOriginX, self.sliderImageView.center.y);
    }else {
        self.sliderImageView.center = CGPointMake(offset.x, self.sliderImageView.center.y);
    }
        
    for (CALayer * layer in self.layersArray) {
        if (layer.frame.origin.x < offset.x) {
            layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
        }else{
            layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:149/255.0 blue:32/255.0 alpha:1.0].CGColor;
        }
    }
    
    CGFloat p = (self.sliderImageView.center.x - self.layerOriginX) / (self.frame.size.width - self.layerOriginX * 2);
    self.valueChange(p);
}

-(void)setCurrentTime:(NSString *)time
{
    self.currentLabel.text = time;
}

-(void)setTotalTime:(NSString *)time
{
    self.totalLabel.text = time;
}

-(void)setPostion:(CGFloat)postion
{
    CGFloat pointX = self.layerOriginX + self.frame.size.width * postion;
    for (CALayer * layer in self.layersArray) {
        if (layer.frame.origin.x < pointX) {
            layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
            
        }else{
            layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:149/255.0 blue:32/255.0 alpha:1.0].CGColor;
        }
    }
    
    self.sliderImageView.center = CGPointMake(pointX, self.sliderImageView.center.y);
}

-(UILabel *)currentLabel
{
    if (!_currentLabel) {
        _currentLabel = [[UILabel alloc]init];
        _currentLabel.text = @" 00:00 ";
        _currentLabel.font = [UIFont systemFontOfSize:13];
        _currentLabel.textColor = [UIColor colorWithWhite:1 alpha:0.6];
        _currentLabel.textAlignment = NSTextAlignmentCenter;
        [_currentLabel sizeToFit];
    }
    return _currentLabel;
}

-(UILabel *)totalLabel
{
    if (!_totalLabel) {
        _totalLabel = [[UILabel alloc]init];
        _totalLabel.text = @" 00:00 ";
        _totalLabel.font = [UIFont systemFontOfSize:13];
        _totalLabel.textColor = [UIColor colorWithWhite:1 alpha:0.6];
        _totalLabel.textAlignment = NSTextAlignmentCenter;
        [_totalLabel sizeToFit];
    }
    return _totalLabel;
}

-(NSMutableArray *)layersArray
{
    if (!_layersArray) {
        _layersArray = [[NSMutableArray alloc]init];
    }
    return _layersArray;
}

-(NSArray *)heightArray
{
    if (!_heightArray) {
        
        NSMutableArray * array = [NSMutableArray array];
        for (int i = 0; i < n; i++) {
            int r = 0;
            while (r < 200) {
                r = arc4random() % 1000;
            }
            CGFloat s = r / 1000.0;
            [array addObject:[NSNumber numberWithFloat:s]];
        }
        _heightArray = array;
    }
    return _heightArray;
}

@end
