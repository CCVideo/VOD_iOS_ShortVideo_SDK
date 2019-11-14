//
//  DWShortEditAndUploadViewController.m
//  ShortVideoDemo
//
//  Created by zwl on 2019/10/28.
//  Copyright © 2019 Myself. All rights reserved.
//

#import "DWShortEditAndUploadViewController.h"

@interface DWShortEditAndUploadViewController ()

@property(nonatomic,assign)CGFloat notchTop;
@property(nonatomic,strong)MBProgressHUD * hud;

@end

@implementation DWShortEditAndUploadViewController

-(instancetype)init
{
    if (self == [super init]) {
        self.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];

    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.removeFromSuperViewOnHide = YES;
    self.hud.label.text = @"正在处理中";
    
    UIButton * leftButton = [DWControl initButtonWithFrame:CGRectZero ButtonType:UIButtonTypeCustom Title:nil Image:@"icon_back.png" Target:self Action:@selector(leftButtonAction) AndTag:0];
    [self.view addSubview:leftButton];
    [leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@12);
        make.top.equalTo(@(self.notchTop + 15));
        make.width.and.height.equalTo(@30);
    }];
    
    //回到前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void)leftButtonAction
{
    self.didDismiss();
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)endEditWithSuccess:(BOOL)success
{
//    [self.hud hideAnimated:YES];

    if (!success) {
        self.hud.mode = MBProgressHUDModeText;
        self.hud.label.text = @"处理失败，请返回上一页重试";
    }else{
        self.hud.mode = MBProgressHUDModeText;
        self.hud.label.text = @"处理完成";
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];

}

-(void)enterForegroundNotification
{
    self.hud.mode = MBProgressHUDModeText;
    self.hud.label.text = @"处理失败，请返回上一页重试";
}

-(CGFloat)notchTop
{
    if (@available(iOS 11.0, *)) {
        return [[UIApplication sharedApplication] delegate].window.safeAreaInsets.top > 0 ? 22 : 0;
    }
    return 0;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
