//
//  ZWLControl.h
//  HFWG
//
//  Created by zwl on 15/7/13.
//  Copyright (c) 2015年 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DWControl : NSObject

/**
 params:1.frame 2.color 3.tag(0为不设置tag) 4.alpha
 */
+(UIView *)initViewWithFrame:(CGRect)frame BackgroundColor:(UIColor *)color Tag:(NSInteger)tag AndAlpha:(CGFloat)alpha;

/**
 params:1.frame 2.image(图片名称)
 */
+(UIImageView *)initImageViewWithFrame:(CGRect)frame AndImage:(NSString *)image;

/**
 parmas:1.frame 2.buttonType 3.title 4.image(图片名称) 5.target 6.action 7.tag(0为不设置tag)
 */
+(UIButton *)initButtonWithFrame:(CGRect)frame ButtonType:(UIButtonType)buttonType Title:(NSString *)title Image:(NSString *)image Target:(id)target Action:(SEL)action AndTag:(NSInteger)tag;

/**
 parmas:1.frame 2.titile 3.textColor 4.textAlignment 5.font
 */
+(UILabel *)initLabelWithFrame:(CGRect)frame Title:(NSString *)title TextColor:(UIColor *)color TextAlignment:(NSTextAlignment)textAlignment AndFont:(UIFont *)font;

/**
 parmas:1.frame 2.style 3.delegate
*/
+(UITableView *)initTableViewFrame:(CGRect)frame Style:(UITableViewStyle)style DelegateAndDataSource:(id)delegate;

@end
