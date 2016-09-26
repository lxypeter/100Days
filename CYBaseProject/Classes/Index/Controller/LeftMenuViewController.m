//
//  LeftMenuViewController.m
//  100Days
//
//  Created by Peter Lee on 16/8/30.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import "LeftMenuViewController.h"

@implementation LeftSideViewOption

- (instancetype)initWithWithTitle:(NSString *)title imageName:(NSString *)imageName className:(NSString *)className{
    self = [super init];
    if (self) {
        _title = title;
        _className = className;
        _imageName = imageName;
    }
    return self;
}

+ (instancetype)optionWithTitle:(NSString *)title imageName:(NSString *)imageName className:(NSString *)className{
    return [[LeftSideViewOption alloc]initWithWithTitle:title imageName:imageName className:className];
}

@end

@interface LeftMenuViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (nonatomic, strong) NSArray *optionsArray;

@end

@implementation LeftMenuViewController

#pragma mark - lazy load
- (NSArray *)optionsArray{
    if (!_optionsArray) {
        LeftSideViewOption *recordOption = [LeftSideViewOption optionWithTitle:NSLocalizedString(@"Target Records", nil) imageName:@"leftview_record" className:@"TargetListViewController"];
        
        LeftSideViewOption *reminderOption = [LeftSideViewOption optionWithTitle:NSLocalizedString(@"Timed Reminder", nil) imageName:@"leftview_notification" className:@"TimeReminderViewController"];
        
        _optionsArray = @[recordOption,reminderOption];
    }
    return _optionsArray;
}

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureSubViews];
}

- (void)viewWillAppear:(BOOL)animated{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userName = [userDefaults stringForKey:kUserNameKey];
    if (![NSString isBlankString:userName]) {
        self.nameLabel.text = userName;
    }
    NSData *userHeaderData = [userDefaults dataForKey:kUserHeaderKey];
    if (userHeaderData) {
        self.headerImageView.image = [UIImage imageWithData:userHeaderData];
    }
}

- (void)configureSubViews{
    self.headerImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.headerImageView.layer.borderWidth = 3;
}

- (IBAction)clickModifyButton:(id)sender {
    if (self.modifyButtonActionBlock) {
        self.modifyButtonActionBlock();
    }
}

- (IBAction)clickHeaderButton:(id)sender {
    if (self.headerButtonActionBlock) {
        self.headerButtonActionBlock();
    }
}

#pragma mark - tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.optionsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"LeftViewCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    LeftSideViewOption *option = self.optionsArray[indexPath.row];
    cell.textLabel.text = option.title;
    cell.imageView.image = [UIImage imageNamed:option.imageName];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    LeftSideViewOption *option = self.optionsArray[indexPath.row];
    if (self.leftSideOptionBlock) {
        self.leftSideOptionBlock(option);
    }
}

@end
