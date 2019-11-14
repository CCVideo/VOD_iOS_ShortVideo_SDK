//
//  ZWLControl.m
//  HFWG
//
//  Created by zwl on 15/7/13.
//  Copyright (c) 2015年 . All rights reserved.
//

#import "DWControl.h"

@implementation DWControl

+(UIView *)initViewWithFrame:(CGRect)frame BackgroundColor:(UIColor *)color Tag:(NSInteger)tag AndAlpha:(CGFloat)alpha;
{
    UIView * view = [[UIView alloc]initWithFrame:frame];
    view.backgroundColor = color;
    view.alpha = alpha;
    if (tag != 0) {
        view.tag = tag;
    }
    return view;
}

+(UIImageView *)initImageViewWithFrame:(CGRect)frame AndImage:(NSString *)image
{
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:frame];
    imageView.image = [UIImage imageNamed:image];
    return imageView;
    
}

+(UIButton *)initButtonWithFrame:(CGRect)frame ButtonType:(UIButtonType)buttonType Title:(NSString *)title Image:(NSString *)image Target:(id)target Action:(SEL)action AndTag:(NSInteger)tag
{
    UIButton * button = [UIButton buttonWithType:buttonType];
    button.frame = frame;
    [button setTitle:title forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    if (tag != 0) {
        button.tag = tag;
    }
    return button;
}

+(UILabel *)initLabelWithFrame:(CGRect)frame Title:(NSString *)title TextColor:(UIColor *)color TextAlignment:(NSTextAlignment)textAlignment AndFont:(UIFont *)font
{
    UILabel * label = [[UILabel alloc]initWithFrame:frame];
    label.text = title;
    label.textColor = color;
    label.textAlignment = textAlignment;
    label.font = font;
    return label;
}

+(UITableView *)initTableViewFrame:(CGRect)frame Style:(UITableViewStyle)style Delegate:(id)delegate DataSource:(id)dataSource
{
    UITableView * tableView = [[UITableView alloc]initWithFrame:frame style:style];
    tableView.delegate = delegate;
    tableView.dataSource = delegate;
    return tableView;
}

@end
