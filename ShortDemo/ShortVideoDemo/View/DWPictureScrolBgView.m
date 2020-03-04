//
//  DWPictureScrolBgView.m
//  ShortVideoDemo
//
//  Created by zwl on 2019/12/30.
//  Copyright © 2019 Myself. All rights reserved.
//

#import "DWPictureScrolBgView.h"

@interface DWPictureScrolBgView () <UIScrollViewDelegate>

@property(nonatomic,strong)NSArray * imagesArray;

@property(nonatomic,assign)CGFloat buttonTotalWidth;//图片+转场按钮总长度
@property(nonatomic,strong)UIScrollView * scrollView;
@property(nonatomic,strong)UIImageView * flagImageView;

@property(nonatomic,assign)NSInteger preImageIndex;//当前选中图片下标
@property(nonatomic,assign)NSInteger preTransitionIndex;//当前选中转场下标

@property(nonatomic,assign)CGFloat tapOffsetX;//记录点击按钮时偏移量
@property(nonatomic,assign)CGFloat buttonPositionWidth;//记录按钮偏移位置

@end

static CGFloat left = 90.0;

@implementation DWPictureScrolBgView

- (instancetype)initWithImageArray:(NSArray *)imagesArray
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:38/255.0 green:38/255.0 blue:40/255.0 alpha:1];
        
        self.imagesArray = imagesArray;
        
        //默认选中第一张图片
        self.preImageIndex = 0;
        self.preTransitionIndex = -1;
        
        [self initUI];
        
        self.buttonPositionWidth = 0;
        
    }
    return self;
}

-(void)setImageIndex:(NSInteger)index WithStyle:(NSInteger)style
{
    //style 0 无 1 放大 2 缩小 3 左滑 4 右滑
    NSArray * titles = @[@"",@"放大",@"缩小",@"左滑",@"右滑"];
    DWPictureScrolImageButton * button = (DWPictureScrolImageButton *)[self.scrollView viewWithTag:100 + index];
    [button setTitle:[titles objectAtIndex:style] forState:UIControlStateNormal];
    
}

-(void)setImageIndex:(NSInteger)index WithDuration:(CGFloat)duration;
{
    UILabel * label = (UILabel *)[self.scrollView viewWithTag:1000 + index];
    label.text = [NSString stringWithFormat:@"%.1fs",duration];
}

-(void)setTransitionIndex:(NSInteger)index WithStyle:(NSInteger)style
{
    //style 0 无 1 重叠 2 闪黑 3 闪白 4 圆形
    NSArray * transitionImages = @[@"icon_small_transition_add.png",@"icon_small_transition_style1.png",@"icon_small_transition_style2.png",@"icon_small_transition_style3.png",@"icon_small_transition_style4.png"];
    NSArray * transitionImagesSelect = @[@"icon_small_transition_add_select.png",@"icon_small_transition_style1_select.png",@"icon_small_transition_style2_select.png",@"icon_small_transition_style3_select.png",@"icon_small_transition_style4_select.png"];;
    
    UIButton * button = (UIButton *)[self.scrollView viewWithTag:200 + index];
    [button setBackgroundImage:[UIImage imageNamed:[transitionImages objectAtIndex:style]] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:[transitionImagesSelect objectAtIndex:style]] forState:UIControlStateSelected];
}

-(void)setTransitionIndex:(NSInteger)index WithDuration:(CGFloat)duration
{
    UILabel * label = (UILabel *)[self.scrollView viewWithTag:2000 + index];
    label.text = [NSString stringWithFormat:@"%.1fs",duration];
}

-(NSInteger)selectImageIndex
{
    return self.preImageIndex;
}

-(NSInteger)selectTransitionIndex
{
    return self.preTransitionIndex;
}

-(void)setScrollViewOffsetWithPercentage:(CGFloat)percentage
{
//    CGFloat w = self.scrollView.contentSize.width - self.beginPositionX;
    //buttonWidth
    CGFloat w = self.buttonTotalWidth + 5 - self.buttonPositionWidth;
//    这里位置计算有问题。。。
    //当前偏移量 + w * percentage
//    还需要一个值来计算当前的偏移量
    CGFloat offsetX = self.tapOffsetX + w * percentage;
    
    self.scrollView.contentOffset = CGPointMake(offsetX, 0);
    
//    NSLog(@"percentage:%f offsetX:%f",percentage,offsetX);
}

#pragma mark - action
-(void)clearButtonSelectIsTransition:(BOOL)isTransition
{
    if (isTransition) {
        //清空图片选中状态
        if (self.preImageIndex != -1) {
            DWPictureScrolImageButton * preButton = (DWPictureScrolImageButton *)[self.scrollView viewWithTag:100 + self.preImageIndex];
            preButton.selected = NO;
            
            self.preImageIndex = -1;
        }
    }else{
        //清空转场选中状态
        if (self.preTransitionIndex != -1) {
            UIButton * preButton = (UIButton *)[self.scrollView viewWithTag:200 + self.preTransitionIndex];
            preButton.selected = NO;
            
            self.preTransitionIndex = -1;
        }
    }
}

-(void)imageButtonAction:(DWPictureScrolImageButton *)button
{
    //100 + i
    if (button.selected) {
        return;
    }
    
    if (self.preImageIndex != -1) {
        DWPictureScrolImageButton * preButton = (DWPictureScrolImageButton *)[self.scrollView viewWithTag:100 + self.preImageIndex];
        preButton.selected = NO;
    }
    [self clearButtonSelectIsTransition:NO];
    
    button.selected = !button.selected;
    self.preImageIndex = button.tag - 100;
    
    [self.delegate pictureScrolBgViewDidSelectImage:self.preImageIndex];
    
    //修改contentOffset
    self.scrollView.contentOffset = CGPointMake(button.frame.origin.x - left - (button.tag == 100 ? 5 : 0), 0);
    self.buttonPositionWidth = button.frame.origin.x - (left + 5);
    self.tapOffsetX = self.scrollView.contentOffset.x;
}

-(void)transitionButtonAction:(UIButton *)button
{
    //200 + i
    if (button.selected) {
        return;
    }
    
    if (self.preTransitionIndex != -1) {
        UIButton * preButton = (UIButton *)[self.scrollView viewWithTag:200 + self.preTransitionIndex];
        preButton.selected = NO;
    }
    [self clearButtonSelectIsTransition:YES];

    button.selected = !button.selected;
    self.preTransitionIndex = button.tag - 200;
    
    [self.delegate pictureScrolBgViewDidSelectTransition:self.preTransitionIndex];

    //取转场按钮前一个图片按钮
    UIButton * imageButton = [self.scrollView viewWithTag:button.tag - 200 + 100];
    //修改contentOffset
    self.scrollView.contentOffset = CGPointMake(imageButton.frame.origin.x - left - (imageButton.tag == 100 ? 5 : 0), 0);
    self.buttonPositionWidth = imageButton.frame.origin.x - (left + 5);
    self.tapOffsetX = self.scrollView.contentOffset.x;
}

#pragma mark - delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //停止动画，等进度条滑动完毕
    if ([self.delegate respondsToSelector:@selector(pictureScrolBgViewBeginDragging)]) {
        [self.delegate pictureScrolBgViewBeginDragging];
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
//    NSLog(@"scrollViewDidEndDragging willDecelerate:%d",decelerate);
    //重新开始动画效果
    if (!decelerate) {
        [self resetAnimationWithOffset:scrollView.contentOffset];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self resetAnimationWithOffset:scrollView.contentOffset];
}

//通过frame 计算当前控件
-(void)resetAnimationWithOffset:(CGPoint)offset
{
    CGFloat offsetX = offset.x;
    for (int i = 0; i < self.imagesArray.count; i++) {
        DWPictureScrolImageButton * imageButton = (DWPictureScrolImageButton *)[self.scrollView viewWithTag:100 + i];
        CGRect buttonFrame = CGRectMake(imageButton.frame.origin.x - offsetX, imageButton.frame.origin.y, imageButton.frame.size.width, imageButton.frame.size.height);
        if (CGRectContainsPoint(buttonFrame, self.flagImageView.center)) {
            [self imageButtonAction:imageButton];
            break;
        }
        
        UIButton * transitionButton = [self.scrollView viewWithTag:200 + i];
        CGRect transitionButtonFrame = CGRectMake(transitionButton.frame.origin.x - offsetX, transitionButton.frame.origin.y, transitionButton.frame.size.width, transitionButton.frame.size.height);
        if (CGRectContainsPoint(transitionButtonFrame, self.flagImageView.center)) {
            [self transitionButtonAction:transitionButton];
            break;
        }
    }
}

#pragma mark - init
-(void)initUI
{
    self.scrollView = [[UIScrollView alloc]init];
    self.scrollView.bounces = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.delegate = self;
    [self addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.top.equalTo(@0);
        make.width.equalTo(@(ScreenWidth));
        make.height.equalTo(@61);
    }];
    
    self.flagImageView = [[UIImageView alloc]init];
    self.flagImageView.image = [UIImage imageNamed:@"icon_picture_slider.png"];
    [self addSubview:self.flagImageView];
    [self.flagImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(left));
        make.centerY.equalTo(self);
        make.width.equalTo(@2);
        make.height.equalTo(@50);
    }];
    
    CGFloat space = 5;
    CGFloat buttonWidth = 40;
    CGFloat buttonHeight = 25;
    CGFloat transitionWidth = 22;
    
    self.buttonTotalWidth = (space + buttonWidth) + (buttonWidth + transitionWidth) * (self.imagesArray.count - 1) + 3;
    
    for (int i = 0; i < self.imagesArray.count; i++) {
        DWPictureScrolImageButton * imageButton = [DWPictureScrolImageButton buttonWithType:UIButtonTypeCustom];
        UIImage * image = [self.imagesArray objectAtIndex:i];
        [imageButton setBackgroundImage:image forState:UIControlStateNormal];
        imageButton.tag = 100 + i;
        [imageButton addTarget:self action:@selector(imageButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        imageButton.layer.masksToBounds = YES;
        imageButton.layer.cornerRadius = 2;
        imageButton.titleLabel.font = [UIFont systemFontOfSize:9];
        [imageButton setTitleColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateNormal];
        imageButton.titleLabel.backgroundColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:0.2];
        imageButton.titleLabel.textAlignment = NSTextAlignmentRight;
        [self.scrollView addSubview:imageButton];
        [imageButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(left + 5 + (buttonWidth + transitionWidth) * i));
            make.centerY.equalTo(self);
            make.width.equalTo(@(buttonWidth));
            make.height.equalTo(@(buttonHeight));
        }];
        
        UILabel * imageTimeLabel = [DWControl initLabelWithFrame:CGRectZero Title:@"3s" TextColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.6] TextAlignment:NSTextAlignmentCenter AndFont:[UIFont systemFontOfSize:9]];
        imageTimeLabel.tag = 1000 + i;
        [self.scrollView addSubview:imageTimeLabel];
        [imageTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(imageButton.mas_top).offset(-3);
            make.left.equalTo(imageButton);
            make.width.equalTo(imageButton);
            make.height.equalTo(@9);
        }];
        
        if (i == 0) {
            imageButton.selected = YES;
        }
        
        if (i != 0) {
            UIButton * transitionButton = [DWControl initButtonWithFrame:CGRectZero ButtonType:UIButtonTypeCustom Title:nil Image:nil Target:self Action:@selector(transitionButtonAction:) AndTag:200 + i - 1];
            [transitionButton setBackgroundImage:[UIImage imageNamed:@"icon_small_transition_add.png"] forState:UIControlStateNormal];
            [transitionButton setBackgroundImage:[UIImage imageNamed:@"icon_small_transition_add_select.png"] forState:UIControlStateSelected];
            [self.scrollView addSubview:transitionButton];
            [transitionButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(imageButton.mas_left);
                make.centerY.equalTo(imageButton);
                make.width.and.height.equalTo(@(transitionWidth));
            }];
            
            UILabel * transitionTimeLabel = [DWControl initLabelWithFrame:CGRectZero Title:@"0s" TextColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.6] TextAlignment:NSTextAlignmentCenter AndFont:[UIFont systemFontOfSize:9]];
            transitionTimeLabel.tag = 2000 + i - 1;
            [self.scrollView addSubview:transitionTimeLabel];
            [transitionTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(transitionButton);
                make.top.equalTo(transitionButton.mas_bottom).offset(4.5);
                make.width.equalTo(transitionButton);
                make.height.equalTo(@9);
            }];
        }
        
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    self.scrollView.contentSize = CGSizeMake(self.buttonTotalWidth + ScreenWidth,61);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

@implementation DWPictureScrolImageButton

-(CGRect)titleRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(self.frame.size.width - 20, self.frame.size.height - 10, 20, 10);
}

-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (selected) {
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor colorWithRed:255/255.0 green:149/255.0 blue:32/255.0 alpha:1.0].CGColor;
    }else{
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    }
}

@end
