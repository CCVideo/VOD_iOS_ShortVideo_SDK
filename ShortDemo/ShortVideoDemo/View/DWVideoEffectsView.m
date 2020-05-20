//
//  DWVideoEffectsView.m
//  ShortVideoDemo
//
//  Created by zwl on 2020/2/26.
//  Copyright © 2020 Myself. All rights reserved.
//

#import "DWVideoEffectsView.h"
#import "DWVideoPreviewView.h"

@interface DWVideoEffectsView ()
 
@property(nonatomic,assign)CGFloat notchTop;
@property(nonatomic,assign)CGFloat notchBottom;

//视频当前播放位置
@property(nonatomic,assign)CGFloat position;
@property(nonatomic,assign)BOOL isRepeat;
@property(nonatomic,assign)UITapGestureRecognizer * currentTap;

@property(nonatomic,assign)NSURL * videoUrl;

@property(nonatomic,strong)UIView * maskView;
@property(nonatomic,strong)UIView * bgView;

@property(nonatomic,strong)UIView * topFuncBgView;

//预览图
@property(nonatomic,strong)UIView * previewBgView;
@property(nonatomic,strong)DWVideoPreviewView * videoPreviewView;

//特效列表
@property(nonatomic,strong)UIScrollView * effectBgScrollView;

@end

@implementation DWVideoEffectsView

-(instancetype)initWithVideoURL:(NSURL *)videoURL
{
    self = [super init];
    if (self) {
        
        self.videoUrl = videoURL;
        
        self.isRepeat = NO;
                
        self.maskView = [DWControl initViewWithFrame:CGRectZero BackgroundColor:[UIColor clearColor] Tag:0 AndAlpha:1];
        [self addSubview:self.maskView];
        [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
        [self.maskView addGestureRecognizer:tap];
        
        [self initBgView];
        [self initTopBgView];
        [self initPreviewBgView];
        [self initEffectBgView];
        
    }
    return self;
}

//设置当前播放位置
-(void)setPosition:(CGFloat)position WithRepeat:(BOOL)isRepeat
//-(void)setPosition:(CGFloat)position
{
    self.position = position;

//    NSLog(@"zwl position %lf isRepeat:%d",self.position,isRepeat);
    
    //记录当前状态，如果在选中特效时从头开始加载视频，取消响应事件
    if (isRepeat && self.currentTap) {
        self.isRepeat = YES;
        self.currentTap.state = UIGestureRecognizerStateCancelled;
    }

    [self.videoPreviewView setStartPosition:self.position];
}

//-(void)changeProgress:(CGFloat)progress
//{
//    [self.videoPreviewView changeProgress:progress];
//}

#pragma mark - action
-(void)dismiss
{
    if (self.currentTap) {
        return;
    }
    
    [self.videoPreviewView dismissAllColorBlock];
        
//    [self removeFromSuperview];
    self.hidden = YES;

    if ([self.delegate respondsToSelector:@selector(videoEffectsViewDismiss)]) {
        [self.delegate videoEffectsViewDismiss];
    }
    
    NSLog(@"zwl test dismiss");
}

-(void)closeButtonAction
{
    [self dismiss];
}

-(void)unDoButtonAction
{
    [self.videoPreviewView undoLastColorBlock];

    if ([self.delegate respondsToSelector:@selector(videoEffectsViewUndo)]) {
        [self.delegate videoEffectsViewUndo];
    }
}

-(void)sureButtonAction
{
    [self.videoPreviewView sureColorBlock];
    
    if ([self.delegate respondsToSelector:@selector(videoEffectsViewSure)]) {
        [self.delegate videoEffectsViewSure];
    }
}

-(void)effectButtonGestureAction:(UILongPressGestureRecognizer *)longPress
{
    self.currentTap = longPress;

    switch (longPress.state) {
        case UIGestureRecognizerStateBegan:
            {
                DWVideoEffectsButton * button = (DWVideoEffectsButton *)longPress.view;
                button.selected = YES;
                
                if ([self.delegate respondsToSelector:@selector(videoEffectsViewStartAddEffect:)]) {
                    [self.delegate videoEffectsViewStartAddEffect:button.tag - 100];
                }
                
                [self.videoPreviewView startAddColorBlockWithPosition:self.position];
            }
            break;
            
        case UIGestureRecognizerStateEnded:
            {
                DWVideoEffectsButton * button = (DWVideoEffectsButton *)longPress.view;
                button.selected = NO;
                                                
                if ([self.delegate respondsToSelector:@selector(videoEffectsViewStopAddEffect)]) {
                    [self.delegate videoEffectsViewStopAddEffect];
                }
                                
                [self.videoPreviewView stopAddColorBlockWithPosition:self.position];
                
                self.isRepeat = NO;
                self.currentTap = nil;
            }
            break;
            
        case UIGestureRecognizerStateCancelled:
           {
               DWVideoEffectsButton * button = (DWVideoEffectsButton *)longPress.view;
               button.selected = NO;
                              
               if ([self.delegate respondsToSelector:@selector(videoEffectsViewStopAddEffect)]) {
                   [self.delegate videoEffectsViewStopAddEffect];
               }
               
               [self.videoPreviewView stopAddColorBlockWithPosition:1];
               
               self.isRepeat = NO;
               self.currentTap = nil;

           }
            break;
        default:
            break;
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
        make.height.equalTo(@(195 + self.notchBottom));
    }];
}

-(void)initTopBgView
{
    self.topFuncBgView = [DWControl initViewWithFrame:CGRectZero BackgroundColor:[UIColor colorWithWhite:0 alpha:0.8] Tag:0 AndAlpha:1];
    [self.bgView addSubview:self.topFuncBgView];
    [self.topFuncBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.equalTo(@0);
        make.right.equalTo(@0);
        make.height.equalTo(@40);
    }];
        
    UIButton * closeButton = [DWControl initButtonWithFrame:CGRectZero ButtonType:UIButtonTypeCustom Title:nil Image:@"icon_edit_close.png" Target:self Action:@selector(closeButtonAction) AndTag:0];
    [self.topFuncBgView addSubview:closeButton];
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@12);
        make.width.and.height.equalTo(@30);
        make.centerY.equalTo(self.topFuncBgView);
    }];
    
    UIButton * unDoButton = [DWControl initButtonWithFrame:CGRectZero ButtonType:UIButtonTypeCustom Title:nil Image:@"icon_edit_undo.png" Target:self Action:@selector(unDoButtonAction) AndTag:0];
    [self.topFuncBgView addSubview:unDoButton];
    [unDoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@(-(30 + 12 + 10)));
        make.width.and.height.equalTo(closeButton);
        make.centerY.equalTo(closeButton);
    }];
    
    UIButton * sureButton = [DWControl initButtonWithFrame:CGRectZero ButtonType:UIButtonTypeCustom Title:nil Image:@"icon_edit_sure.png" Target:self Action:@selector(sureButtonAction) AndTag:0];
    [self.topFuncBgView addSubview:sureButton];
    [sureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@(-12));
        make.width.and.height.equalTo(closeButton);
        make.centerY.equalTo(closeButton);
    }];

}

-(void)initPreviewBgView
{
    self.previewBgView = [DWControl initViewWithFrame:CGRectZero BackgroundColor:[UIColor colorWithWhite:1 alpha:0.03] Tag:0 AndAlpha:1];
    [self.bgView addSubview:self.previewBgView];
    [self.previewBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(@0);
        make.top.equalTo(self.topFuncBgView.mas_bottom);
        make.height.equalTo(@87);
    }];
    
    UILabel * tsLabel = [DWControl initLabelWithFrame:CGRectZero Title:@"选择位置后，按住使用效果" TextColor:[UIColor whiteColor] TextAlignment:NSTextAlignmentCenter AndFont:[UIFont systemFontOfSize:13]];
    [self.previewBgView addSubview:tsLabel];
    [tsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(@0);
        make.top.equalTo(@10);
        make.height.equalTo(@13);
    }];
    
    self.videoPreviewView = [[DWVideoPreviewView alloc]initWithFrame:CGRectMake(12, 10 + 13 + 4, ScreenWidth - 24, 50) VideoUrl:self.videoUrl];
//    self.videoPreviewView.delegate = self;
    [self.previewBgView addSubview:self.videoPreviewView];
}

-(void)initEffectBgView
{
    NSArray * titles = @[@"动感",@"闪屏",@"灵魂出窍",@"毛刺",@"抖动"];
    NSArray * images = @[@"icon_effect_style1",@"icon_effect_style2",@"icon_effect_style3",@"icon_effect_style4",@"icon_effect_style5"];
    
    CGFloat buttonWidth = 45.0;
    
    self.effectBgScrollView = [[UIScrollView alloc]init];
    self.effectBgScrollView.showsVerticalScrollIndicator = NO;
    self.effectBgScrollView.showsHorizontalScrollIndicator = NO;
    self.effectBgScrollView.contentSize = CGSizeMake(12 * (titles.count + 1) + buttonWidth * titles.count, 63);
    [self.bgView addSubview:self.effectBgScrollView];
    [self.effectBgScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.top.equalTo(self.previewBgView.mas_bottom);
        make.width.equalTo(@(ScreenWidth));
        make.height.equalTo(@63);
    }];
    
    for (int i = 0; i < titles.count; i++) {
        DWVideoEffectsButton * button = [DWVideoEffectsButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:[titles objectAtIndex:i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithWhite:1 alpha:0.6] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:255/255.0 green:149/255.0 blue:32/255.0 alpha:1.0] forState:UIControlStateSelected];
        button.titleLabel.font = [UIFont systemFontOfSize:11];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[images objectAtIndex:i]]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_highlighted.png",[images objectAtIndex:i]]] forState:UIControlStateSelected];
        
        UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(effectButtonGestureAction:)];
        [button addGestureRecognizer:longPress];
        
        button.tag = 100 + i;
        [self.effectBgScrollView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(12 + (12 + buttonWidth) * i));
            make.centerY.equalTo(self.effectBgScrollView);
            make.width.equalTo(@(buttonWidth));
            make.height.equalTo(@(63));
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

@implementation DWVideoEffectsButton

-(CGRect)titleRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(0, 30 + 9.5, self.frame.size.width, 11);
}

-(CGRect)imageRectForContentRect:(CGRect)contentRect
{
    return CGRectMake((self.frame.size.width - 30) / 2.0, 0, 30, 30);
}

@end
