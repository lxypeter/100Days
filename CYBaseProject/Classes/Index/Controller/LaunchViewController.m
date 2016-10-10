//
//  LaunchViewController.m
//  100Days
//
//  Created by Peter Lee on 2016/10/10.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import "LaunchViewController.h"

@interface LaunchViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;

@end

@implementation LaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.logoImageView.image = [UIImage imageNamed:NSLocalizedString(@"100Day_Base", nil)];
}

@end
