//
//  FirstViewController.m
//  ShortVideoDemo
//
//  Created by luyang on 2017/7/31.
//  Copyright © 2017年 Myself. All rights reserved.
//

#import "FirstViewController.h"
#import "ShortVideoViewController.h"
@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn =[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame =CGRectMake((ScreenWidth-120)/2,(ScreenHeight-30)/2,120, 30);
    [btn setTitle:@"录制小视频" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.titleLabel.font =[UIFont systemFontOfSize:18];
    btn.titleLabel.textAlignment =NSTextAlignmentCenter;
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
}

- (void)btnClick{

    ShortVideoViewController *viewCtrl =[[ShortVideoViewController alloc]init];
   
    [self.navigationController pushViewController:viewCtrl animated:YES];


}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
