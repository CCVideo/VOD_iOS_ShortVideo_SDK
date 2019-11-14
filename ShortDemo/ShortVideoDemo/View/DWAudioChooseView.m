//
//  DWAudioChooseView.m
//  ShortVideoDemo
//
//  Created by zwl on 2019/10/29.
//  Copyright © 2019 Myself. All rights reserved.
//

#import "DWAudioChooseView.h"

@interface DWAudioChooseView ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UITableView * tableView;

@end

@implementation DWAudioChooseView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [[UIApplication sharedApplication].keyWindow addSubview:self];
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0);
            make.top.equalTo(@0);
            make.width.equalTo(@(ScreenWidth));
            make.height.equalTo(@(ScreenHeight));
        }];
        
        [self initUI];

    }
    return self;
}

#pragma mark - action
-(void)closeButtonAction
{
    BOOL select = NO;
    for (NSDictionary * dict in self.array) {
        if ([[dict objectForKey:@"isSelect"] boolValue]) {
            select = YES;
            break;
        }
    }
    self.cancel(select);

    [self removeFromSuperview];
}
/*
-(void)leftButtonAction
{
    self.cancel();

    [self removeFromSuperview];
}

-(void)sureButtonAction
{
    BOOL select = NO;
    for (NSDictionary * dict in self.array) {
        if ([[dict objectForKey:@"isSelect"] boolValue]) {
            select = YES;
            break;
        }
    }

    if (!select) {
        [@"请选择音乐" showAlert];
        return;
    }
    [self removeFromSuperview];
}
 */

#pragma mark - delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.array.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DWAudioChooseTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[DWAudioChooseTableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    
    NSDictionary * audioDict = [self.array objectAtIndex:indexPath.row];
    [cell setAudioName:[audioDict objectForKey:@"name"] Author:[audioDict objectForKey:@"author"] Time:[audioDict objectForKey:@"time"] WithSelect:[[audioDict objectForKey:@"isSelect"] boolValue]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //取路径
    NSDictionary * audioDict = [self.array objectAtIndex:indexPath.row];
    if ([[audioDict objectForKey:@"isSelect"] boolValue]) {
        [audioDict setValue:@NO forKey:@"isSelect"];
        
        self.chooseAudio(nil);
    }else{
        for (NSDictionary * dict in self.array) {
            if ([[dict objectForKey:@"isSelect"] boolValue]) {
                [dict setValue:@NO forKey:@"isSelect"];
            }
        }
        [audioDict setValue:@YES forKey:@"isSelect"];
        
        NSString * audioPath = [audioDict objectForKey:@"path"];
        
        self.chooseAudio(audioPath);
    }
    
    [tableView reloadData];
}

#pragma mark - init
-(void)initUI
{
    UIView * naBgView = [DWControl initViewWithFrame:CGRectZero BackgroundColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0] Tag:0 AndAlpha:1];
    [self addSubview:naBgView];
    [naBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.equalTo(@0);
        make.width.equalTo(@(ScreenWidth));
        make.height.equalTo(@64);
    }];
    
    UIButton * closeButton = [DWControl initButtonWithFrame:CGRectZero ButtonType:UIButtonTypeCustom Title:nil Image:@"icon_edit_close.png" Target:self Action:@selector(closeButtonAction) AndTag:0];
    [naBgView addSubview:closeButton];
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(@12);
        make.right.equalTo(@(-12));
        make.top.equalTo(@27);
        make.width.and.height.equalTo(@30);
    }];
    
//    UIButton * sureButton = [DWControl initButtonWithFrame:CGRectZero ButtonType:UIButtonTypeCustom Title:nil Image:@"icon_edit_sure.png" Target:self Action:@selector(sureButtonAction) AndTag:0];
//    [naBgView addSubview:sureButton];
//    [sureButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(@(-12));
//        make.top.equalTo(leftButton);
//        make.width.and.height.equalTo(leftButton);
//    }];
    
    UILabel * titleLabel = [DWControl initLabelWithFrame:CGRectZero Title:@"选择音乐" TextColor:[UIColor whiteColor] TextAlignment:NSTextAlignmentCenter AndFont:[UIFont systemFontOfSize:15]];
    [naBgView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(naBgView);
        make.centerY.equalTo(closeButton);
        make.width.equalTo(@100);
        make.height.equalTo(@15);
    }];
    
    self.tableView = [[UITableView alloc]init];
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor blackColor];
    [self addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(naBgView.mas_bottom);
        make.left.and.width.equalTo(naBgView);
        make.bottom.equalTo(@0);
    }];
    
}

@end

@interface DWAudioChooseTableViewCell ()

@property(nonatomic,strong)UILabel * titleLabel;
@property(nonatomic,strong)UILabel * timeLabel;
@property(nonatomic,strong)UIImageView * iconImageView;

@property(nonatomic,strong)NSString * name;
@property(nonatomic,strong)NSString * author;

@end

@implementation DWAudioChooseTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = [UIColor colorWithRed:45/255.0 green:46/255.0 blue:48/255.0 alpha:1.0];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.titleLabel = [DWControl initLabelWithFrame:CGRectZero Title:nil TextColor:[UIColor whiteColor] TextAlignment:NSTextAlignmentLeft AndFont:[UIFont systemFontOfSize:15]];
        [self.contentView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@12);
            make.right.equalTo(@(-80));
            make.height.equalTo(@15);
            make.centerY.equalTo(self.contentView);
        }];
        
        self.timeLabel = [DWControl initLabelWithFrame:CGRectZero Title:nil TextColor:[UIColor colorWithWhite:1 alpha:0.4] TextAlignment:NSTextAlignmentRight AndFont:[UIFont systemFontOfSize:15]];
        [self.contentView addSubview:self.timeLabel];
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-12));
            make.width.equalTo(@50);
            make.height.equalTo(@15);
            make.centerY.equalTo(self.contentView);
        }];
        
        self.iconImageView = [DWControl initImageViewWithFrame:CGRectZero AndImage:@""];
        self.iconImageView.hidden = YES;
        [self.contentView addSubview:self.iconImageView];
        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.timeLabel);
            make.centerY.equalTo(self.contentView);
            make.width.and.height.equalTo(@30);
        }];
        
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
        NSMutableArray *images = [NSMutableArray array];

        for (int i = 1; i <= 7; ++i) {
            UIImage * image = [UIImage imageNamed:[NSString stringWithFormat:@"icon_music_spectrum_%d.png",i]];
            [images addObject:(__bridge id)image.CGImage];
        }
        animation.values = images;
        animation.duration = 2;
        animation.repeatCount = HUGE_VALF;
        [self.iconImageView.layer addAnimation:animation forKey:nil];
    }
    return self;
}

-(void)setAudioName:(NSString *)name Author:(NSString *)author Time:(NSString *)time WithSelect:(BOOL)isSelect
{
    self.name = name;
    self.author = author;
    
    self.timeLabel.text = time;
        
    NSString * title = [NSString stringWithFormat:@"%@  %@",self.name,self.author];
    NSMutableAttributedString * attrString = [[NSMutableAttributedString alloc]initWithString:title];
    
    if (isSelect) {
        [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:255/255.0 green:149/255.0 blue:32/255.0 alpha:1.0] range:NSMakeRange(0, title.length)];
    }else{
        [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithWhite:1 alpha:0.6] range:NSMakeRange(title.length - self.author.length, self.author.length)];
    }
    
    self.timeLabel.hidden = isSelect;
    self.iconImageView.hidden = !isSelect;
    
    self.titleLabel.attributedText = attrString;
}

/*
-(void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    NSString * title = [NSString stringWithFormat:@"%@  %@",self.name,self.author];
    NSMutableAttributedString * attrString = [[NSMutableAttributedString alloc]initWithString:title];
    
    if (selected) {
        [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:255/255.0 green:149/255.0 blue:32/255.0 alpha:1.0] range:NSMakeRange(0, title.length)];
    }else{
        [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithWhite:1 alpha:0.6] range:NSMakeRange(title.length - self.author.length, self.author.length)];
    }
    
    self.timeLabel.hidden = selected;
    self.iconImageView.hidden = !selected;
    
    self.titleLabel.attributedText = attrString;
}
 */

@end

