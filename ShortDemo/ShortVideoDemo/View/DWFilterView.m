//
//  DWFilterView.m
//  ShortVideoDemo
//
//  Created by zwl on 2019/9/11.
//  Copyright © 2019 Myself. All rights reserved.
//

#import "DWFilterView.h"

@interface DWFilterView ()

@property(nonatomic,strong)UIView * maskBgView;
@property(nonatomic,strong)UIView * bgView;
@property(nonatomic,assign)NSInteger index;
@property(nonatomic,assign)CGFloat notchBottom;

@end

@implementation DWFilterView

-(instancetype)init
{
    if (self == [super init]) {
        self.hidden = YES;
        [[UIApplication sharedApplication].keyWindow addSubview:self];
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(@0);
            make.top.and.bottom.equalTo(@0);
        }];
        
        self.maskBgView = [DWControl initViewWithFrame:CGRectZero BackgroundColor:[UIColor clearColor] Tag:0 AndAlpha:1];
        [self addSubview:self.maskBgView];
        [self.maskBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
        [self.maskBgView addGestureRecognizer:tap];
        
        self.bgView = [DWControl initViewWithFrame:CGRectZero BackgroundColor:[UIColor colorWithWhite:0 alpha:0.8] Tag:0 AndAlpha:1];
        [self addSubview:self.bgView];
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(@0);
            make.bottom.equalTo(@0);
            make.height.equalTo(@(170 + self.notchBottom));
        }];
        
        UILabel * label = [DWControl initLabelWithFrame:CGRectZero Title:@"滤镜" TextColor:[UIColor whiteColor] TextAlignment:NSTextAlignmentLeft AndFont:[UIFont systemFontOfSize:15]];
        [self.bgView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@12);
            make.top.equalTo(@0);
            make.width.equalTo(@50);
            make.height.equalTo(@31);
        }];
        
//        UIButton * sureButton = [DWControl initButtonWithFrame:CGRectZero ButtonType:UIButtonTypeCustom Title:nil Image:@"icon_sure.png" Target:self Action:@selector(sureButtonAction) AndTag:0];
//        [self.bgView addSubview:sureButton];
//        [sureButton mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.centerY.equalTo(label);
//            make.right.equalTo(@(-12));
//            make.width.and.height.equalTo(@31);
//        }];
        
        NSArray * images = @[@"icon_filter_no.png",@"icon_filter_1.png",@"icon_filter_2.png",@"icon_filter_3.png",@"icon_filter_4.png",@"icon_filter_5.png"];
        NSArray * titles = @[@"",@"清新",@"淡雅",@"白皙",@"复古",@"微光"];

        UIScrollView * bgScrollView = [[UIScrollView alloc]init];
        bgScrollView.showsVerticalScrollIndicator = NO;
        bgScrollView.showsHorizontalScrollIndicator = NO;
        bgScrollView.contentSize = CGSizeMake(12 * 2 + 60 * images.count + 10 * (images.count - 1), 170 - 31);
        [self.bgView addSubview:bgScrollView];
        [bgScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0);
            make.top.equalTo(label.mas_bottom);
            make.width.equalTo(@(ScreenWidth));
            make.height.equalTo(@(170 - 31));
        }];
        
        for (int i = 0; i < images.count; i++) {
            DWFilterViewButton * button = [DWFilterViewButton buttonWithType:UIButtonTypeCustom];
            [button setImage:[UIImage imageNamed:[images objectAtIndex:i]] forState:UIControlStateNormal];
            [button setTitle:[titles objectAtIndex:i] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithWhite:1 alpha:0.7] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithRed:255/255.0 green:149/255.0 blue:32/255.0 alpha:1.0] forState:UIControlStateSelected];
            button.titleLabel.font = [UIFont systemFontOfSize:13];
            button.titleLabel.textAlignment = NSTextAlignmentCenter;
            button.tag = 100 + i;
            [button addTarget:self action:@selector(filterButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [bgScrollView addSubview:button];
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@(12 + (60 + 10) * i));
                make.centerY.equalTo(bgScrollView);
                make.width.equalTo(@60);
                make.height.equalTo(@(80));
            }];
        }
        
        self.index = 0;
    }
    return self;
}

-(CGFloat)notchBottom
{
    if (@available(iOS 11.0, *)) {
           return [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0 ? 34 : 0;
       }
       return 0;
}

//-(void)sureButtonAction
//{
//    [self dismiss];
//}

-(void)filterButtonAction:(UIButton *)button
{
    if (button.selected) {
        return;
    }
    
    UIButton * preButton = (UIButton *)[self viewWithTag:self.index + 100];
    preButton.selected = NO;
    
    button.selected = !button.selected;
    self.index = button.tag - 100;
    
    [self.delegate DWFilterViewFinishWithIndex:self.index];
}

-(void)show
{
    self.hidden = NO;
}

-(void)dismiss
{
    self.hidden = YES;
    
    [self.delegate DWFilterViewDismiss];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

@implementation DWFilterViewButton

-(CGRect)imageRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(0, 0, 60, 60);
}

-(CGRect)titleRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(0, 67, 60, 13);
}

@end
