//
//  DWShootingBottomView.m
//  ShortVideoDemo
//
//  Created by zwl on 2019/9/11.
//  Copyright © 2019 Myself. All rights reserved.
//

#import "DWShootingBottomView.h"

@interface DWShootingBottomView ()

@property(nonatomic,strong)UIButton * recordButton;

@end

@implementation DWShootingBottomView

-(instancetype)init
{
    if (self == [super init]) {
        
        self.recordButton = [DWControl initButtonWithFrame:CGRectZero ButtonType:UIButtonTypeCustom Title:nil Image:nil Target:self Action:@selector(recordButtonAction) AndTag:0];
        [self.recordButton setBackgroundImage:[UIImage imageNamed:@"icon_record.png"] forState:UIControlStateNormal];
        self.recordButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.recordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self addSubview:self.recordButton];
        [self.recordButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.and.height.equalTo(@75);
        }];
    }
    return self;
}

-(void)resetRecordButtonStatus
{
    self.recordButton.selected = NO;
}

-(void)setStyle:(NSInteger)style
{    
    for (UIView * view in self.subviews) {
        if (view != self.recordButton) {
            [view removeFromSuperview];
        }
    }
    
    CGFloat leftSpace = ((ScreenWidth - 75) / 2.0 - 39 * 2) / 3.0;
    CGFloat rightSpace = ((ScreenWidth - 75) / 2.0 - 39) / 2.0;
    if (style == 1) {
        NSArray * leftTitlesArray = @[@"美颜",@"滤镜"];
        NSArray * leftImagesArray = @[@"icon_beauty_close.png",@"icon_filter.png"];
        for (int i = 0; i < leftImagesArray.count; i++) {
            DWShootingBottomButton * button = [DWShootingBottomButton buttonWithType:UIButtonTypeCustom];
            button.titleLabel.font = [UIFont systemFontOfSize:13];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setTitle:[leftTitlesArray objectAtIndex:i] forState:UIControlStateNormal];
            button.titleLabel.textAlignment = NSTextAlignmentCenter;
            [button setImage:[UIImage imageNamed:[leftImagesArray objectAtIndex:i]] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(oneButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            if (i == 0) {
                [button setImage:[UIImage imageNamed:@"icon_beauty_open.png"] forState:UIControlStateSelected];
            }
            button.tag = 100 + i;
            [self addSubview:button];
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@(leftSpace + (39 + leftSpace) * i));
                make.centerY.equalTo(self.recordButton);
                make.width.equalTo(@39);
                make.height.equalTo(@53);
            }];
        }
        
        DWShootingBottomButton * rightButton = [DWShootingBottomButton buttonWithType:UIButtonTypeCustom];
        rightButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [rightButton setTitle:@"上传" forState:UIControlStateNormal];
        rightButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [rightButton addTarget:self action:@selector(oneButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [rightButton setImage:[UIImage imageNamed:@"icon_upload.png"] forState:UIControlStateNormal];
        rightButton.tag = 102;
        [self addSubview:rightButton];
        [rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.recordButton.mas_right).offset(rightSpace);
            make.centerY.equalTo(self.recordButton);
            make.width.equalTo(@39);
            make.height.equalTo(@53);
        }];
    }
    
    if (style == 2) {
        UIButton * rightButton = [DWControl initButtonWithFrame:CGRectZero ButtonType:UIButtonTypeCustom Title:nil Image:nil Target:self Action:@selector(finishButtonAction) AndTag:0];
        [rightButton setBackgroundImage:[UIImage imageNamed:@"icon_save.png"] forState:UIControlStateNormal];
        [self addSubview:rightButton];
        [rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.recordButton.mas_right).offset(rightSpace);
            make.centerY.equalTo(self.recordButton);
            make.width.and.height.equalTo(@40);
        }];
    }
    
    if (style == 3) {

        UIButton * leftButton = [DWControl initButtonWithFrame:CGRectZero ButtonType:UIButtonTypeCustom Title:nil Image:nil Target:self Action:@selector(deleteButtonAction) AndTag:0];
        [leftButton setBackgroundImage:[UIImage imageNamed:@"icon_delete.png"] forState:UIControlStateNormal];
        [self addSubview:leftButton];
        [leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(rightSpace));
            make.centerY.equalTo(self.recordButton);
            make.width.and.height.equalTo(@40);
        }];
        
        UIButton * rightButton = [DWControl initButtonWithFrame:CGRectZero ButtonType:UIButtonTypeCustom Title:nil Image:nil Target:self Action:@selector(finishButtonAction) AndTag:0];
        [rightButton setBackgroundImage:[UIImage imageNamed:@"icon_save.png"] forState:UIControlStateNormal];
        [self addSubview:rightButton];
        [rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.recordButton.mas_right).offset(rightSpace);
            make.centerY.equalTo(self.recordButton);
            make.width.and.height.equalTo(@40);
        }];
    }
}

-(void)setRecordTime:(CGFloat)time
{
    if (time == 0) {
        [self.recordButton setTitle:@"" forState:UIControlStateNormal];
        return;
    }
    [self.recordButton setTitle:[NSString stringWithFormat:@"%.0fs",time] forState:UIControlStateNormal];
}

#pragma mark - action
-(void)recordButtonAction
{
    self.recordButton.selected = !self.recordButton.selected;
    
    [self.delegate DWShootingBottomViewRecordButtonAction:self.recordButton.selected];
}

//1
-(void)oneButtonAction:(UIButton *)button
{
    // 100 + i
    if (button.tag == 100) {
        [self.delegate DWShootingBottomViewBeautyButtonAction];
    }
    
    if (button.tag == 101) {
        [self.delegate DWShootingBottomViewFilterButtonAction];
    }
    
    if (button.tag == 102) {
        [self.delegate DWShootingBottomViewUploadButtonAction];
    }
}

//2
-(void)finishButtonAction
{
    [self.delegate DWShootingBottomViewFinishButtonAction];
}

//3
-(void)deleteButtonAction
{
    [self.delegate DWShootingBottomViewDeleteButtonAction];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

@implementation DWShootingBottomButton

-(CGRect)imageRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(0, 0, 39, 39);
}

-(CGRect)titleRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(0, 40, 39, 13);
}

@end
