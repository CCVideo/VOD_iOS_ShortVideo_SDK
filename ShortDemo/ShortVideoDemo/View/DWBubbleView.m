//
//  DWBubbleView.m
//  ShortVideoDemo
//
//  Created by zwl on 2019/9/18.
//  Copyright © 2019 Myself. All rights reserved.
//

#import "DWBubbleView.h"
#import "LINConversionView.h"
#import "ICGVideoTrimmerView.h"
#import <AVFoundation/AVFoundation.h>

@interface DWBubbleView ()<LINConversionViewDelegate,ICGVideoTrimmerDelegate>

@property(nonatomic,assign)CGFloat notchTop;
@property(nonatomic,assign)CGFloat notchBottom;
@property(nonatomic,strong)UIView * maskView;
@property(nonatomic,strong)UIView * stickerBgView;
@property(nonatomic,strong)UIView * videoTrimmerBgView;

@end

@implementation DWBubbleView

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
-(void)dismiss
{    
    [self removeFromSuperview];
    
    [self.delegate DWBubbleViewDismiss];
}

-(void)stickerButtonAction:(UIButton *)button
{
    [self.delegate DWBubbleViewDidSelect:button.tag - 100];
    
    [self dismiss];
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
    
    UILabel * label = [DWControl initLabelWithFrame:CGRectZero Title:@"气泡" TextColor:[UIColor whiteColor] TextAlignment:NSTextAlignmentLeft AndFont:[UIFont systemFontOfSize:15]];
    [self.stickerBgView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@12);
        make.top.equalTo(@0);
        make.width.equalTo(@50);
        make.height.equalTo(@31);
    }];
    
    NSArray * images = @[@"icon_bubble_1.png",@"icon_bubble_2.png",@"icon_bubble_3.png",@"icon_bubble_4.png",@"icon_bubble_5.png"];
    
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


@interface DWBubbleInputView ()

@property(nonatomic,strong)UITextView * textView;

@end

@implementation DWBubbleInputView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self == [super initWithFrame:frame]) {
        
        self.userInteractionEnabled = YES;

        self.placeholderLabel = [DWControl initLabelWithFrame:CGRectMake(32, 102, 114, 49) Title:@"点击T输入文字" TextColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0] TextAlignment:NSTextAlignmentCenter AndFont:[UIFont systemFontOfSize:14]];
//        self.placeholderLabel.adjustsFontSizeToFitWidth = YES;
        self.placeholderLabel.numberOfLines = 2;
        [self addSubview:self.placeholderLabel];
        
        self.textView = [[UITextView alloc]initWithFrame:CGRectMake(32, 102, 114, 49)];
        self.textView.font = [UIFont systemFontOfSize:14];
        self.textView.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
        self.textView.backgroundColor = [UIColor colorWithRed:254/255.0 green:214/255.0 blue:162/255.0 alpha:1.0];
        self.textView.hidden = YES;
        [self addSubview:self.textView];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChangeNotification) name:UITextViewTextDidChangeNotification object:nil];
    }
    return self;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    self.placeholderLabel.frame = CGRectMake(frame.size.width * 32 / 180.0, frame.size.height * 102 / 180, frame.size.width - (frame.size.width * 32 / 180.0) * 2, frame.size.height * 49 / 180);
    self.textView.frame = CGRectMake(frame.size.width * 32 / 180.0, frame.size.height * 102 / 180, frame.size.width - (frame.size.width * 32 / 180.0) * 2, frame.size.height * 49 / 180);
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
}

-(void)beginEdit
{
    self.isEdit = YES;
    
    self.placeholderLabel.hidden = YES;
    self.textView.hidden = NO;
    [self.textView becomeFirstResponder];
}

-(void)textDidChangeNotification
{
    if (self.textView.text.length > 10) {
        self.textView.text = [self.textView.text substringWithRange:NSMakeRange(0, 10)];
    }
    self.placeholderLabel.text = self.textView.text;
}

-(void)endEdit
{
    self.isEdit = NO;

    [self endEditing:YES];
    self.placeholderLabel.hidden = NO;
    self.textView.hidden = YES;
    if (self.textView.text.length == 0) {
        self.placeholderLabel.text = @"点击T输入文字";
    }else{
        self.placeholderLabel.text = self.textView.text;
    }
}

@end
