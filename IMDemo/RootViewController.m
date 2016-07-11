//
//  RootViewController.m
//  IMDemo
//
//  Created by Liwy on 16/7/10.
//  Copyright © 2016年 Liwy. All rights reserved.
//

#import "RootViewController.h"
#import "FriendListViewController.h"

#import "HRCChatViewController.h"

#import "EMSDK.h"

@interface RootViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView * chatTableView;
@property (nonatomic, strong) NSMutableArray <EMConversation *>* dataSource;

- (void)initializeDataSource;
- (void)initializeUserInterface;
- (void)configueNavigationbar;

- (void)addButtonItemPressed:(UIBarButtonItem *)sender;

- (void)refreshData;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
  [self initializeDataSource];
  [self configueNavigationbar];
  [self initializeUserInterface];
}

#pragma mark -- <UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
//  cell.textLabel.text = @"hello world";
  cell.textLabel.text = ((EMTextMessageBody *)_dataSource[indexPath.row].latestMessage.body).text;
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  HRCChatViewController * chatViewController = [[HRCChatViewController alloc] initWithToId:_dataSource[indexPath.row].conversationId];
  [self.navigationController pushViewController:chatViewController animated:YES];
  
}

#pragma mark -- button action
- (void)addButtonItemPressed:(UIBarButtonItem *)sender
{
  FriendListViewController * friendList = [[FriendListViewController alloc] init];
  [self.navigationController pushViewController:friendList animated:YES];

}

#pragma mark -- other methods
- (void)refreshData
{
  //获得所有会话
  NSArray * array = [[EMClient sharedClient].chatManager getAllConversations];
  
  self.dataSource = array.mutableCopy;
  NSLog(@"array = %@", array);
}

#pragma mark -- initialize methods
- (void)initializeDataSource
{
  [self refreshData];
}

- (void)initializeUserInterface
{
  [self.view addSubview:self.chatTableView];
}

- (void)configueNavigationbar
{
  self.navigationItem.title = @"消息列表";
  
  //添加按钮
  UIBarButtonItem * addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonItemPressed:)];
  self.navigationItem.rightBarButtonItem = addItem;
  
}

#pragma mark -- getter
- (UITableView *)chatTableView
{
  if (_chatTableView == nil) {
    UITableView * tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.delegate = self;
    
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    _chatTableView = tableView;
  }
  return _chatTableView;
}


@end
