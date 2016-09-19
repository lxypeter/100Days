//
//  CYBaseViewController.m
//  100Days
//
//  Created by Peter Lee on 16/9/3.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import "CYBaseViewController.h"

@interface CYBaseViewController ()

@end

@implementation CYBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureBackButton];
}

- (void)configureBackButton{
    // 设置左边按钮
    UIButton *backBtn = [[UIButton alloc] init];
    [backBtn setImage:[UIImage imageNamed:@"back_arrow"] forState:UIControlStateNormal];
    backBtn.bounds = CGRectMake(0, 0, 30, 30);
    
    // 左边按钮添加监听事件并添加至导航栏中
    [backBtn addTarget:self action:@selector(backToLastController) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backItem;
}

- (void)backToLastController {
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated: YES];
}

@end
