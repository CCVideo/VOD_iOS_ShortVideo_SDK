//
//  DWPictureSetBgView.m
//  ShortVideoDemo
//
//  Created by zwl on 2019/12/30.
//  Copyright © 2019 Myself. All rights reserved.
//

#import "DWPictureSetBgView.h"

@interface DWPictureSetBgView ()

@property(nonatomic,assign)NSInteger preIndex;

@property(nonatomic,assign)DWPictureSetStyle style;

@property(nonatomic,strong)DWPictureSetBgButton * setAllButton;

@property(nonatomic,strong)UILabel * currentLabel;
@property(nonatomic,strong)UILabel * minLabel;
@property(nonatomic,strong)UISlider * slider;
@property(nonatomic,strong)UILabel * maxLabel;

@end

//static CGFloat imageBeginDuration = 1.0;

@implementation DWPictureSetBgView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:30/255.0 green:30/255.0 blue:32/255.0 alpha:1];
        
        self.preIndex = 0;
        self.imageMinTime = 1.0;
        self.imageMaxTime = 5.0;
        self.transitionMinTime = 0.0;
        self.transitionMaxTime = 1.0;
        
        [self initUI];
        
        [self resetStyle:DWPictureSetStylePicture DurationPercentage:0.5 AndSelectIndex:0];
    }
    return self;
}

-(void)resetStyle:(DWPictureSetStyle)style DurationPercentage:(CGFloat)durationPercentage AndSelectIndex:(NSInteger)selectIndex
{
    self.style = style;
    [self changeUIWithDurationPercentage:durationPercentage AndSelectIndex:selectIndex];
    
}

-(void)changeUIWithDurationPercentage:(CGFloat)durationPercentage AndSelectIndex:(NSInteger)selectIndex
{
    //修改标题
    NSString * title;
    NSArray * funcTitles;
    NSArray * funcImages;
    NSArray * funcImagesSelect;
    CGFloat minTime;
    CGFloat maxTime;
    
    if (self.style == DWPictureSetStylePicture) {
        //图片
        title = @"应用到全部图片";
        funcTitles = @[@"放大",@"缩小",@"左滑",@"右滑"];
        funcImages = @[@"icon_picture_style1.png",@"icon_picture_style2.png",@"icon_picture_style3.png",@"icon_picture_style4.png"];
        funcImagesSelect = @[@"icon_picture_style1_select.png",@"icon_picture_style2_select.png",@"icon_picture_style3_select.png",@"icon_picture_style4_select.png"];
        minTime = self.imageMinTime;
        maxTime = self.imageMaxTime;
    }else{
        //转场
        title = @"应用到全部转场";
        funcTitles = @[@"重叠",@"闪黑",@"闪白",@"圆形"];
        funcImages = @[@"icon_transition_style1.png",@"icon_transition_style2.png",@"icon_transition_style3.png",@"icon_transition_style4.png"];
        funcImagesSelect = @[@"icon_transition_style1_select.png",@"icon_transition_style2_select.png",@"icon_transition_style3_select.png",@"icon_transition_style4_select.png"];
        minTime = self.transitionMinTime;
        maxTime = self.transitionMaxTime;
    }
    
    [self.setAllButton setTitle:title forState:UIControlStateNormal];
    
    for (int i = 0; i < 4; i++) {
        DWPictureSetFuncButton * button = (DWPictureSetFuncButton *)[self viewWithTag:100 + i + 1];
        [button setTitle:[funcTitles objectAtIndex:i] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:[funcImages objectAtIndex:i]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:[funcImagesSelect objectAtIndex:i]] forState:UIControlStateSelected];
    }
    
    self.minLabel.text = [NSString stringWithFormat:@"%.1fs",minTime];
    self.maxLabel.text = [NSString stringWithFormat:@"%.1fs",maxTime];
    
    self.slider.value = durationPercentage;

    self.currentLabel.text = [NSString stringWithFormat:@"%.1fs",durationPercentage * (maxTime - minTime) + minTime];
    
    //修改动画按钮状态
    if (self.preIndex != selectIndex) {
        DWPictureSetFuncButton * preButton = (DWPictureSetFuncButton *)[self viewWithTag:100 + self.preIndex];
        preButton.selected = NO;
        
        DWPictureSetFuncButton * button = (DWPictureSetFuncButton *)[self viewWithTag:100 + selectIndex];
        button.selected = YES;
        
        self.preIndex = selectIndex;
    }

}

#pragma mark - action
-(void)setAllButtonAction
{
    [self.delegate pictureSetBgViewTotalSetStyle:self.style Index:self.preIndex];
}

-(void)sliderEndedAction
{
    
    CGFloat maxTime;
    CGFloat minTime;
    if (self.style == DWPictureSetStylePicture) {
        minTime = self.imageMinTime;
        maxTime = self.imageMaxTime;
    }else{
        minTime = self.transitionMinTime;
        maxTime = self.transitionMaxTime;
    }
    
    CGFloat duration = self.slider.value * (maxTime - minTime) + minTime;
//    self.currentLabel.text = [NSString stringWithFormat:@"%.1fs",duration];
    
    [self.delegate pictureSetBgViewStyle:self.style DurationChange:duration];
}

-(void)sliderValueChange
{
    CGFloat maxTime;
    CGFloat minTime;
    if (self.style == DWPictureSetStylePicture) {
        minTime = self.imageMinTime;
        maxTime = self.imageMaxTime;
    }else{
        minTime = self.transitionMinTime;
        maxTime = self.transitionMaxTime;
    }
    
    CGFloat duration = self.slider.value * (maxTime - minTime) + minTime;
    self.currentLabel.text = [NSString stringWithFormat:@"%.1fs",duration];

//    [self.delegate pictureSetBgViewStyle:self.style DurationChange:duration];
}

-(void)funcButtonAction:(DWPictureSetFuncButton *)button
{
    //100 + i
    if (button.selected) {
        return;
    }
    
    DWPictureSetFuncButton * preButton = (DWPictureSetFuncButton *)[self viewWithTag:100 + self.preIndex];
    preButton.selected = NO;
    button.selected = !button.selected;
    self.preIndex = button.tag - 100;
    
    [self.delegate pictureSetBgViewStyle:self.style Index:self.preIndex];
}

#pragma mark - init
-(void)initUI
{
    self.setAllButton = [DWPictureSetBgButton buttonWithType:UIButtonTypeCustom];
    [self.setAllButton setImage:[UIImage imageNamed:@"icon_picture_apply.png"] forState:UIControlStateNormal];
    self.setAllButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.setAllButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.setAllButton setTitle:@"应用到全部图片" forState:UIControlStateNormal];
    [self.setAllButton addTarget:self action:@selector(setAllButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.setAllButton];
    [self.setAllButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@15);
        make.top.equalTo(@0);
        make.width.equalTo(@110);
        make.height.equalTo(@40);
    }];
    
    self.minLabel = [DWControl initLabelWithFrame:CGRectZero Title:@"0.0s" TextColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.5] TextAlignment:NSTextAlignmentCenter AndFont:[UIFont systemFontOfSize:9]];
    [self addSubview:self.minLabel];
    
    self.slider = [[UISlider alloc]init];
    [self.slider setThumbImage:[UIImage imageNamed:@"icon_picture_slider_circle.png"] forState:UIControlStateNormal];
    [self.slider setMinimumTrackImage:[[UIColor colorWithRed:255/255.0 green:149/255.0 blue:32/255.0 alpha:1.0] createImageWithSize:CGSizeMake(10, 2)] forState:UIControlStateNormal];
    [self.slider setMaximumTrackImage:[[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.3] createImageWithSize:CGSizeMake(10, 3)] forState:UIControlStateNormal];

    [self.slider addTarget:self action:@selector(sliderEndedAction) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    [self.slider addTarget:self action:@selector(sliderValueChange) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.slider];
    
    self.maxLabel = [DWControl initLabelWithFrame:CGRectZero Title:@"0.0s" TextColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.5] TextAlignment:NSTextAlignmentCenter AndFont:[UIFont systemFontOfSize:9]];
    [self addSubview:self.maxLabel];
    
    [self.minLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.setAllButton.mas_right).offset(35);
        make.centerY.equalTo(self.setAllButton);
        make.width.equalTo(@20);
        make.height.equalTo(@9);
    }];
    
    [self.maxLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-30);
        make.centerY.equalTo(self.setAllButton);
        make.width.equalTo(self.minLabel);
        make.height.equalTo(self.minLabel);
    }];
    
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.minLabel.mas_right).offset(10);
        make.centerY.equalTo(self.minLabel);
        make.right.equalTo(self.maxLabel.mas_left).offset(-10);
        make.height.equalTo(@20);
    }];
    
    self.currentLabel = [DWControl initLabelWithFrame:CGRectZero Title:@"0.0s" TextColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1] TextAlignment:NSTextAlignmentCenter AndFont:[UIFont systemFontOfSize:10]];
    [self addSubview:self.currentLabel];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    UIImageView * sliderCircleImageView = nil;
    for (UIView * subView in self.slider.subviews) {
        if ([subView isKindOfClass:[UIImageView class]]) {
            sliderCircleImageView = (UIImageView *)subView;
        }
    }
    
    [self.currentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(sliderCircleImageView);
        make.bottom.equalTo(self.slider.mas_top);
        make.width.equalTo(@24);
        make.height.equalTo(@10);
    }];
        
    for (int i = 0; i < 5; i++) {
        DWPictureSetFuncButton * funcButton = [DWPictureSetFuncButton buttonWithType:UIButtonTypeCustom];
        [funcButton setTitleColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.6] forState:UIControlStateNormal];
        [funcButton setTitleColor:[UIColor colorWithRed:255/255.0 green:149/255.0 blue:32/255.0 alpha:1.0] forState:UIControlStateSelected];
        funcButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        funcButton.titleLabel.font = [UIFont systemFontOfSize:11];
        [funcButton addTarget:self action:@selector(funcButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        funcButton.tag = 100 + i;
        [self addSubview:funcButton];
        if (i == 0) {
            [funcButton setImage:[UIImage imageNamed:@"icon_picture_no.png"] forState:UIControlStateNormal];
            [funcButton setImage:[UIImage imageNamed:@"icon_picture_no_select.png"] forState:UIControlStateSelected];
            [funcButton setTitle:@"无" forState:UIControlStateNormal];
            funcButton.selected = YES;
        }
        
        [funcButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(12 + (30 + 10) * i));
            make.top.equalTo(self.setAllButton.mas_bottom).offset(15);
            make.width.equalTo(@30);
            make.height.equalTo(@56);
        }];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

@implementation DWPictureSetBgButton

-(CGRect)imageRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(0, (self.frame.size.height - 15) / 2.0, 15, 15);
}

-(CGRect)titleRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(20, 0, self.frame.size.width - 20, self.frame.size.height);
}

@end


@implementation DWPictureSetFuncButton

-(CGRect)imageRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(0, 0, 30, 30);
}

-(CGRect)titleRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(0, 45, 30, 11);
}

@end
