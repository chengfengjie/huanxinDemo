//
//  ViewController.m
//  IMDemo
//
//  Created by Liwy on 16/7/10.
//  Copyright © 2016年 Liwy. All rights reserved.
//

#import "ViewController.h"

#import "EMSDK.h"
#import "EMMessage.h"

@interface ViewController () <EMChatManagerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userNameField;

@property (weak, nonatomic) IBOutlet UITextField *passwordField;

- (IBAction)buttonPressed:(UIButton *)sender;
- (IBAction)loginButtonPressed:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  
  //注册
  
//  EMError * error = [[EMClient sharedClient] registerWithUsername:@"lisi" password:@"123456"];
//  if (error == nil) {
//    NSLog(@"注册成功");
//  }
  
//  EMError * error = [[EMClient sharedClient] loginWithUsername:@"zhangsan" password:@"123456"];
//  if (error == nil) {
//    NSLog(@"登录成功");
//  }
  
//  [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
  
}

- (void)buttonPressed:(UIButton *)sender
{
  //发送文字消息
//  NSLog(@"发送文字消息");
  //构建文字消息
  EMTextMessageBody * textBody = [[EMTextMessageBody alloc] initWithText:@"您好呀"];
  NSString * from = [[EMClient sharedClient] currentUsername];
  
  [[EMClient sharedClient].chatManager getConversation:@"lisi" type:EMConversationTypeChat createIfNotExist:YES];

  //生成message
  EMMessage * message = [[EMMessage alloc] initWithConversationID:@"lisi" from:from to:@"lisi" body:textBody ext:nil]; //最后一个参数为扩展,附加内容
  message.chatType = EMChatTypeChat;//单聊
  
  [[EMClient sharedClient].chatManager asyncSendMessage:message progress:^(int progress) {
    NSLog(@"progress %d", progress);
  } completion:^(EMMessage *message, EMError *error) {
    NSLog(@"error message = %@, %@", message.body, error.description);
  }];
  
}

- (IBAction)loginButtonPressed:(id)sender {
//  NSLog(@"登录");
  EMError * error = [[EMClient sharedClient] loginWithUsername:_userNameField.text password:_passwordField.text];
  if (error == nil) {
    NSLog(@"登录成功");
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];

  }
  
}

- (void)didReceiveMessages:(NSArray *)aMessages
{
  //解析消息
  for (EMMessage * message in aMessages) {
    EMMessageBody * messageBody = message.body;
    
    switch (messageBody.type) {
      case EMMessageBodyTypeText:
      {
        EMTextMessageBody * textBody = (EMTextMessageBody *)messageBody;
        NSLog(@"消息为:%@", textBody.text);
      }
        break;
        
      default:
        break;
    }
    
  }
}

@end







