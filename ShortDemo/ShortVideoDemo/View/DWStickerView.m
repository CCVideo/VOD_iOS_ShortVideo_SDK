//
//  DWStickerView.m
//  ShortVideoDemo
//
//  Created by zwl on 2019/9/16.
//  Copyright © 2019 Myself. All rights reserved.
//

#import "DWStickerView.h"
#import <AVFoundation/AVFoundation.h>

@interface DWStickerView ()

@property(nonatomic,assign)CGFloat notchTop;
@property(nonatomic,assign)CGFloat notchBottom;
@property(nonatomic,strong)UIView * maskView;
@property(nonatomic,strong)UIView * stickerBgView;

@end

@implementation DWStickerView

-(instancetype)init
{
    if (self == [super init]) {
        
        self.maskView = [DWControl initViewWithFrame:CGRectZero BackgroundColor:[UIColor clearColor] Tag:0 AndAlpha:1];
        [self addSubview:self.maskView];
        [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
        [self.maskView addGestureRecognizer:tap];
        
        [self initStickerView];

    }
    return self;
}

#pragma mark - action
-(void)stickerButtonAction:(UIButton *)button
{
    //事件回传
    [self.delegate DWStickerViewDidSelect:button.tag - 100];
    
    [self dismiss];
}

-(void)dismiss
{
    [self removeFromSuperview];
    
    [self.delegate DWStickerViewDismiss];
}

#pragma mark - init
-(void)initStickerView
{
    //贴纸
    self.stickerBgView = [DWControl initViewWithFrame:CGRectZero BackgroundColor:[UIColor colorWithWhite:0 alpha:0.8] Tag:0 AndAlpha:1];
    [self addSubview:self.stickerBgView];
    [self.stickerBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(@0);
        make.bottom.equalTo(@0);
        make.height.equalTo(@(170 + self.notchBottom));
    }];
    
    UILabel * label = [DWControl initLabelWithFrame:CGRectZero Title:@"贴纸" TextColor:[UIColor whiteColor] TextAlignment:NSTextAlignmentLeft AndFont:[UIFont systemFontOfSize:15]];
    [self.stickerBgView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@12);
        make.top.equalTo(@0);
        make.width.equalTo(@50);
        make.height.equalTo(@31);
    }];
    
    NSArray * images = @[@"icon_sticker_1.png",@"icon_sticker_2.png",@"icon_sticker_3.png",@"icon_sticker_4.png",@"icon_sticker_5.png"];
    
    UIScrollView * bgScrollView = [[UIScrollView alloc]init];
    bgScrollView.showsVerticalScrollIndicator = NO;
    bgScrollView.showsHorizontalScrollIndicator = NO;
    bgScrollView.contentSize = CGSizeMake(12 * 2 + 60 * images.count + 10 * (images.count - 1), 170 - 31);
    [self.stickerBgView addSubview:bgScrollView];
    [bgScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.top.equalTo(label.mas_bottom);
        make.width.equalTo(@(ScreenWidth));
        make.height.equalTo(@(170 - 31));
    }];
    
    for (int i = 0; i < images.count; i++) {
        UIButton * button = [DWControl initButtonWithFrame:CGRectZero ButtonType:UIButtonTypeCustom Title:nil Image:[images objectAtIndex:i] Target:self Action:@selector(stickerButtonAction:) AndTag:100 + i];
        button.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [bgScrollView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(12 + (60 + 10) * i));
            make.centerY.equalTo(bgScrollView);
            make.width.equalTo(@60);
            make.height.equalTo(@(80));
        }];
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
