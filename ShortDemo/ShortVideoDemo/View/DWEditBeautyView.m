//
//  DWEditBeautyView.m
//  ShortVideoDemo
//
//  Created by zwl on 2019/9/17.
//  Copyright © 2019 Myself. All rights reserved.
//

#import "DWEditBeautyView.h"

@interface DWEditBeautyView ()

@property(nonatomic,assign)CGFloat notchBottom;

@property(nonatomic,strong)UIView * maskView;

@property(nonatomic,strong)UIView * bgView;
@property(nonatomic,strong)UILabel * whiteningLabel;
@property(nonatomic,strong)UILabel * microderLabel;
@property(nonatomic,strong)UISlider * whiteningSlider;
@property(nonatomic,strong)UISlider * microderSlider;

@end

@implementation DWEditBeautyView

-(instancetype)initWithVideoURL:(NSURL *)videoURL
{
    if (self == [super init]) {
        
        self.frame = [UIScreen mainScreen].bounds;
        self.hidden = YES;

        self.maskView = [DWControl initViewWithFrame:CGRectZero BackgroundColor:[UIColor clearColor] Tag:0 AndAlpha:1];
        [self addSubview:self.maskView];
        [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
        [self.maskView addGestureRecognizer:tap];
         
        self.bgView = [DWControl initViewWithFrame:CGRectZero BackgroundColor:[UIColor colorWithWhite:0 alpha:0.8] Tag:0 AndAlpha:1];
        [self addSubview:self.bgView];
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(@0);
            make.bottom.equalTo(@0);
            make.height.equalTo(@(170 + self.notchBottom));
        }];
        
        UILabel * label = [DWControl initLabelWithFrame:CGRectZero Title:@"美颜" TextColor:[UIColor whiteColor] TextAlignment:NSTextAlignmentLeft AndFont:[UIFont systemFontOfSize:15]];
        [self.bgView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@12);
            make.top.equalTo(@0);
            make.width.equalTo(@50);
            make.height.equalTo(@31);
        }];
 
        NSArray * titles = @[@"美白",@"磨皮"];
        CGFloat space = (170 - 31 - 50 * 2) / 3.0;
        for (int i = 0; i < titles.count; i++) {
            UIView * view = [DWControl initViewWithFrame:CGRectZero BackgroundColor:[UIColor clearColor] Tag:0 AndAlpha:1];
            [self.bgView addSubview:view];
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(label.mas_bottom).offset(space + (space + 50) * i);
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
                self.whiteningLabel = currentLabel;
                self.whiteningSlider = slider;
            }
            if (i == 1) {
                self.microderLabel = currentLabel;
                self.microderSlider = slider;
            }
        }
        
    }
    return self;
}
 
-(void)sliderValueChange:(UISlider *)slider
{
    if (slider.tag == 100) {
        self.whiteningLabel.text = [NSString stringWithFormat:@"%.0f",slider.value];
        [self.delegate DWEditBeautyViewWhiteValueChange:slider.value];
    }
    
    if (slider.tag == 101) {
        self.microderLabel.text = [NSString stringWithFormat:@"%.0f",slider.value];
        [self.delegate DWEditBeautyViewMicroderValueChange:slider.value];
    }
}

-(void)dismiss
{
    [self.delegate DWEditBeautyDismiss];
    
    self.hidden = YES;
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
