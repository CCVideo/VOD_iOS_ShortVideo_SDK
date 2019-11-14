//
//  DWShortEditAndUploadViewController.h
//  ShortVideoDemo
//
//  Created by zwl on 2019/10/28.
//  Copyright © 2019 Myself. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^UploadViewControllerDidDismiss)();


@interface DWShortEditAndUploadViewController : UIViewController

@property(nonatomic,copy)UploadViewControllerDidDismiss didDismiss;

-(void)endEditWithSuccess:(BOOL)success;

@end

