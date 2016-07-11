//
//  FriendListViewController.m
//  IMDemo
//
//  Created by Liwy on 16/7/10.
//  Copyright © 2016年 Liwy. All rights reserved.
//

#import "FriendListViewController.h"
#import "EMSDK.h"

@interface FriendListViewController () <UITableViewDataSource>

@property (nonatomic, strong) UITableView * friendTableView;

- (void)initializeDataSource;
@end

@implementation FriendListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
  [self initializeDataSource];
  
  self.navigationItem.title = @"朋友列表";
  [self.view addSubview:self.friendTableView];
}

#pragma mark -- <UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return nil;
}

- (void)initializeDataSource
{
  EMError * error = nil;
  NSArray * array =  [[EMClient sharedClient].contactManager getContactsFromServerWithError:&error];
  if (error == nil) {
    NSLog(@"haoyou %@", array);
  }
}

- (UITableView *)friendTableView
{
  if (_friendTableView == nil) {
    
    UITableView * tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    
    tableView.dataSource = self;
    
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    _friendTableView = tableView;
  }
  return _friendTableView;
}

@end
