//
//  IndexViewController.m
//  100Days
//
//  Created by Peter Lee on 16/8/30.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import "IndexViewController.h"
#import "MainViewController.h"
#import "LeftMenuViewController.h"
#import "UIColor+HexString.h"
#import "CustInfoSettingViewController.h"

@interface IndexViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic, strong) UINavigationController *mainNaviController;
@property (nonatomic, strong) LeftMenuViewController *leftSideViewController;
@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, assign, getter=isValidPan) BOOL validPan;

@end

@implementation IndexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureSubViews];
}

- (void)viewDidAppear:(BOOL)animated{
    [self checkUserInfo];
}

#pragma mark - configure subViews
- (void)configureSubViews{
    
    //主页面
    MainViewController *mainController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"MainViewController"];
    __weak typeof (self) weakSelf = self;
    mainController.settingButtonEvent = ^{
        [weakSelf clickSettingButton];
    };
    mainController.viewWillAppearEvent = ^{
        [weakSelf.leftSideViewController viewWillAppear:YES];
    };
    
    UINavigationController *mainNaviController = [[UINavigationController alloc]initWithRootViewController:mainController];
    mainNaviController.delegate = self;
    mainNaviController.navigationBar.barTintColor = UICOLOR(@"#81CFE0");
    NSDictionary * dict = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    mainNaviController.navigationBar.titleTextAttributes = dict;
    self.mainNaviController = mainNaviController;
    [self.view addSubview:mainNaviController.view];
    
    //主页面手势
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panMainControllerView:)];
    [self.mainNaviController.view addGestureRecognizer:panGesture];
    
    //遮盖层
    UIView *coverView = [[UIView alloc]initWithFrame:mainController.view.frame];
    coverView.backgroundColor = [UIColor clearColor];
    coverView.hidden = YES;
    [mainNaviController.view addSubview:coverView];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickCoverView:)];
    [coverView addGestureRecognizer:tapGesture];
    self.coverView = coverView;
    
    //左边侧滑栏
    LeftMenuViewController *leftMenuViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"LeftMenuViewController"];
    leftMenuViewController.view.frame = CGRectMake(-ScreenWidth*0.8, 0, ScreenWidth*0.8, ScreenHeight);
    leftMenuViewController.leftSideOptionBlock = ^(LeftSideViewOption *option){
        
        [UIView animateWithDuration:0.25 animations:^{
            [weakSelf slipViewWithDistance:-(ScreenWidth*0.8)];
        }completion:^(BOOL finished) {
            weakSelf.coverView.hidden = YES;
            panGesture.enabled = NO;
        }];
        
        UIViewController *controller = [[NSClassFromString(option.className) alloc]init];
        controller.title = option.title;
        [weakSelf.mainNaviController pushViewController:controller animated:YES];
        
    };
    leftMenuViewController.modifyButtonActionBlock = ^{
        
        [UIView animateWithDuration:0.25 animations:^{
            [weakSelf slipViewWithDistance:-(ScreenWidth*0.8)];
        }completion:^(BOOL finished) {
            weakSelf.coverView.hidden = YES;
        }];
        
        CustInfoSettingViewController *ctrl = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"CustInfoSettingViewController"];
        [weakSelf.mainNaviController presentViewController:ctrl animated:YES completion:nil];
    };
    leftMenuViewController.headerButtonActionBlock = ^{
        
        UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
        ipc.delegate = self;
        ipc.allowsEditing = YES;
        ipc.modalPresentationStyle = UIModalPresentationCustom;
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            UIAlertAction *photoLibraryAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"from the library", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [weakSelf presentViewController:ipc animated:YES completion:nil];
            }];
            [alertController addAction:photoLibraryAction];
        }
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"take photo", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
                [weakSelf presentViewController:ipc animated:YES completion:nil];
            }];
            [alertController addAction:cameraAction];
        }
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
        
        [weakSelf presentViewController:alertController animated:YES completion:nil];
    };
    self.leftSideViewController = leftMenuViewController;
    [self.view addSubview:leftMenuViewController.view];
    
}

- (void)checkUserInfo{
    
    NSString *userName = [[NSUserDefaults standardUserDefaults]stringForKey:kUserNameKey];
    if ([NSString isBlankString:userName]) {
        CustInfoSettingViewController *ctrl = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"CustInfoSettingViewController"];
        ctrl.banClose = YES;
        [self presentViewController:ctrl animated:YES completion:nil];
    }
}

#pragma mark - event method
- (void)clickCoverView:(UITapGestureRecognizer *)tapGest{
    [UIView animateWithDuration:0.25 animations:^{
        [self slipViewWithDistance:-(ScreenWidth*0.8)];
    }completion:^(BOOL finished) {
        self.coverView.hidden = YES;
    }];
}

- (void)panMainControllerView:(UIPanGestureRecognizer *)panGest{
    
    //开始时
    if(panGest.state == UIGestureRecognizerStateBegan){
        CGPoint beginPoint = [panGest locationInView:panGest.view];
        if (beginPoint.x>panGest.view.frame.size.width/5) {
            self.validPan = NO;
        }else{
            self.validPan = YES;
        }
    }
    
    if (!self.isValidPan) return;
    
    CGPoint trans = [panGest translationInView:panGest.view];
    [self slipViewWithDistance:trans.x];
    [panGest setTranslation:CGPointZero inView:panGest.view];
    
    //结束时
    if(panGest.state == UIGestureRecognizerStateEnded){
        if(fabs(panGest.view.frame.origin.x)>self.leftSideViewController.view.frame.size.width/2){
            [UIView animateWithDuration:0.1 animations:^{
                [self slipViewWithDistance:ScreenWidth*0.8 - panGest.view.frame.origin.x];
            }completion:^(BOOL finished) {
                self.coverView.hidden = NO;
            }];
        }else{
            [UIView animateWithDuration:0.1 animations:^{
                [self slipViewWithDistance:-panGest.view.frame.origin.x];
            }completion:^(BOOL finished) {
                self.coverView.hidden = YES;
            }];
        }
    }
}

- (void)clickSettingButton{
    [UIView animateWithDuration:0.25 animations:^{
        [self slipViewWithDistance:ScreenWidth*0.8];
    }completion:^(BOOL finished) {
        self.coverView.hidden = NO;
    }];
}

- (void)slipViewWithDistance:(NSInteger)moveDistance{
    
    if (self.leftSideViewController.view.frame.origin.x+moveDistance<-(ScreenWidth*0.8)) {
        moveDistance = -(ScreenWidth*0.8) - self.leftSideViewController.view.frame.origin.x;
    }
    
    CGRect tempFrame = self.leftSideViewController.view.frame;
    tempFrame.origin.x = tempFrame.origin.x + moveDistance;
    self.leftSideViewController.view.frame = tempFrame;
    
    tempFrame = self.mainNaviController.view.frame;
    tempFrame.origin.x = tempFrame.origin.x + moveDistance;
    self.mainNaviController.view.frame = tempFrame;
    
}

#pragma mark - delegate method
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if([viewController isKindOfClass:[MainViewController class]]){
        [self.mainNaviController.view.gestureRecognizers enumerateObjectsUsingBlock:^(__kindof UIGestureRecognizer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.enabled = YES;
        }];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    // 1.取出照片
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    [userDefults setObject:UIImagePNGRepresentation(info[UIImagePickerControllerEditedImage]) forKey:kUserHeaderKey];
    [userDefults synchronize];
    // 2.退出控制器
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self.leftSideViewController viewWillAppear:YES];
}

@end
