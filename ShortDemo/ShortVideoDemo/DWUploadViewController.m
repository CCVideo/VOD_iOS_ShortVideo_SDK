#import "DWUploadViewController.h"
#import "DWUploadInfoSetupViewController.h"
#import "DWUploadTableViewCell.h"
#import "DWuploadModel.h"
#import "AppDelegate.h"
#import "DWShortTool.h"

#import <MobileCoreServices/MobileCoreServices.h>
#include<AssetsLibrary/AssetsLibrary.h>

@interface DWUploadViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic)DWUploadInfoSetupViewController *uploadInfoSetupViewController;

@property (strong, nonatomic)NSString *videoPath;

@property (strong, nonatomic)UITableView *tableView;

@property (nonatomic,strong)NSMutableArray *videoArray;

@property (nonatomic,assign)NSInteger selectIndex;

/**
 *  定时器用来处理处于wait的任务。
 */
@property (strong, nonatomic)NSTimer *timer;

@end

@implementation DWUploadViewController

- (void)dealloc{

    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = @"点击上传";
        
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"上传"
                                                        image:[UIImage imageNamed:@"tabbar-upload"]
                                                          tag:0];
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.videoArray =[[[NSUserDefaults standardUserDefaults] objectForKey:@"videoArray"] mutableCopy];
    
    
    CGRect frame = [[UIScreen mainScreen] bounds];
  
   
    
    self.tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 96;
    [self.view addSubview:self.tableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadAction:) name:@"uploadVideo" object:nil];
    
    
    
    
}

- (void)uploadAction:(NSNotification *)noti{
    
    /*
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_selectIndex inSection:0];
    
    DWUploadTableViewCell *cell = (DWUploadTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    NSDictionary *dic =noti.userInfo;
    
    self.videoArray =[[[NSUserDefaults standardUserDefaults] objectForKey:@"videoArray"] mutableCopy];
    DWuploadModel *model =[DWuploadModel mj_objectWithKeyValues:self.videoArray[_selectIndex]];
    
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) firstObject];
    
    
    model.videoPath =[NSString stringWithFormat:@"%@/%@",documentPath,model.videoLocalPath];
    model.videoFileSize =[DWShortTool dw_fileSizeAtPath:model.videoPath];

    DWUploader *uploader = [[DWUploader alloc] initWithUserId:DWACCOUNT_USERID
                                                andKey:DWACCOUNT_APIKEY
                                      uploadVideoTitle:dic[@"videoTitle"]
                                      videoDescription:dic[@"videoDescripton"]
                                              videoTag:dic[@"videoTag"]
                                             videoPath:model.videoPath
                                             notifyURL:@"http://www.bokecc.com/"];
    
    uploader.progressBlock = ^(float progress, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite) {
        model.videoUploadProgress = progress;
        model.videoUploadedSize = totalBytesWritten;
        
        [cell updateCellProgress:model];
    };
    
    uploader.finishBlock = ^() {
        
        model.videoUploadStatus = DWUploadStatusFinish;
        [cell updateUploadStatus:model];
        //保存信息
        [self replaceUploadModel:model];
        
    };
    
    uploader.failBlock = ^(NSError *error) {
        
        
        model.videoUploadStatus = DWUploadStatusFail;
        [cell updateUploadStatus:model];
        
    };
    
    uploader.pausedBlock = ^(NSError *error) {
        
        model.videoUploadStatus = DWUploadStatusPause;
        [cell updateUploadStatus:model];
        
    };
    
    uploader.videoContextForRetryBlock = ^(NSDictionary *videoContext) {
        
        model.uploadContext = videoContext;
    };

    
    uploader.timeoutSeconds =20;
    [uploader start];
*/

}

- (void)replaceUploadModel:(DWuploadModel *)model{

    
    self.videoArray =[[[NSUserDefaults standardUserDefaults] objectForKey:@"videoArray"] mutableCopy];
    
    for (int i =0;i <self.videoArray.count;i++) {
        
        NSDictionary *dic =self.videoArray[i];
        
        if ([model.videoLocalPath isEqualToString:dic[@"videoLocalPath"]]) {
            
          [self.videoArray replaceObjectAtIndex:i withObject:[model mj_keyValues]];
            
        }
        
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:self.videoArray forKey:@"videoArray"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewDidAppear:animated];
   
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
     self.videoArray =[[[NSUserDefaults standardUserDefaults] objectForKey:@"videoArray"] mutableCopy];
    
    return [self.videoArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"DWUploadViewCorollerCellId";
    
    
    DWUploadTableViewCell *cell = (DWUploadTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    if(cell == nil){
        
        cell = [[DWUploadTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        
        
    }
    self.videoArray =[[[NSUserDefaults standardUserDefaults] objectForKey:@"videoArray"] mutableCopy];
    DWuploadModel *model =[DWuploadModel mj_objectWithKeyValues:self.videoArray[indexPath.row]];
    
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) firstObject];
    
    model.videoPath =[NSString stringWithFormat:@"%@/%@",documentPath,model.videoLocalPath];
    model.videoFileSize =[DWShortTool dw_fileSizeAtPath:model.videoPath];
    
    [cell setupCell:model];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    
    
    _selectIndex =indexPath.row;
    
    DWUploadInfoSetupViewController *viewCtrl =[[DWUploadInfoSetupViewController alloc]init];
    
    [self.navigationController pushViewController:viewCtrl animated:NO];
    
    


}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        self.videoArray =[[[NSUserDefaults standardUserDefaults] objectForKey:@"videoArray"] mutableCopy];
        [self.videoArray removeObjectAtIndex:indexPath.row];
        
        [[NSUserDefaults standardUserDefaults] setObject:self.videoArray forKey:@"videoArray"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [tableView reloadData];  
    }
}



- (void)videoUploadAlert:(NSString *)info
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:info
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    
    [alert show];
}


@end
