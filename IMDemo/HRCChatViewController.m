//
//  HRCChatViewController.m
//  Huanxin
//
//  Created by chengfj on 16/7/10.
//  Copyright © 2016年 chengfj.com. All rights reserved.
//

#import "HRCChatViewController.h"
#import <EMSDK.h>

#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width

@interface HRCChatViewController () <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate> {
  CGRect tableviewRect;
}

@property (nonatomic,copy) NSString * toId;

@property (nonatomic,strong) UITableView * tableView;

@property (nonatomic,strong) UIView * inputBar;

@property (nonatomic,strong) UITextField * inputTextField;

@property (nonatomic,strong) NSMutableArray * chatMessageDicts;

@property (nonatomic,strong) EMConversation * conversation;

@end

@implementation HRCChatViewController
@synthesize inputBar;
@synthesize tableView;
@synthesize inputTextField;

- (instancetype)initWithToId:(NSString *)toId {
  self = [super init];
  if (self) {
    self.toId = toId;
    self.chatMessageDicts = [NSMutableArray array];
    /// 获取会话
    self.conversation = [[EMClient sharedClient].chatManager
                         getConversation:self.toId
                         type:EMConversationTypeChat
                         createIfNotExist:YES];
    
    NSArray * loadMessage = [self.conversation loadMoreMessagesFromId:nil
                                                                limit:200
                                                            direction:EMMessageSearchDirectionUp];
    [loadMessage enumerateObjectsUsingBlock:^(EMMessage * message, NSUInteger idx, BOOL * _Nonnull stop) {
      [self.chatMessageDicts addObject:message];
      [tableView reloadData];
    }];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  /// 监听键盘高度改变
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(inputKeyboardFrameChange:)
                                               name:UIKeyboardWillChangeFrameNotification
                                             object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(inputKeyboardWillHide:)
                                               name:UIKeyboardWillHideNotification
                                             object:nil];
  
  self.title = @"聊天";
  self.edgesForExtendedLayout = UIRectEdgeNone;
  self.automaticallyAdjustsScrollViewInsets = false;
  
  /// 配置TableView
  tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
  tableView.contentInset = UIEdgeInsetsMake(0, 0, 114, 0);
  tableView.dataSource = self;
  tableView.delegate = self;
  [self.view addSubview:tableView];
  tableviewRect = tableView.frame;
  
  /// 输入框的父视图
  CGRect inputBarFrame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 50);
  inputBarFrame.origin.y = CGRectGetHeight(self.view.frame)-114;
  inputBar = [[UIView alloc] initWithFrame:inputBarFrame];
  inputBar.backgroundColor = [UIColor lightGrayColor];
  [self.view addSubview:inputBar];
  
  /// 输入textField的背景色
  UIView * inputTextFieldBG = [[UIView alloc] init];
  inputTextFieldBG.frame = CGRectMake(10, 7.5, CGRectGetWidth(inputBar.frame)-70, 35);
  inputTextFieldBG.backgroundColor = [UIColor whiteColor];
  inputTextFieldBG.layer.cornerRadius = 5;
  [inputBar addSubview:inputTextFieldBG];
  
  /// 发送图片按钮
  UIButton * sendImgButton = [UIButton buttonWithType:UIButtonTypeCustom];
  sendImgButton.frame = CGRectMake(CGRectGetMaxX(inputTextFieldBG.frame)+10, 0, 40, 50);
  [sendImgButton setTitle:@"图片" forState:UIControlStateNormal];
  [sendImgButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [inputBar addSubview:sendImgButton];
  
  inputTextField = [[UITextField alloc] init];
  inputTextField.delegate = self;
  inputTextField.returnKeyType = UIReturnKeySend;
  inputTextField.frame = CGRectMake(5, 0, CGRectGetWidth(inputTextFieldBG.frame)-10, 35);
  [inputTextFieldBG addSubview:inputTextField];
  
  [self scrollToBottomAnimate:false];
}

- (void)inputKeyboardFrameChange:(NSNotification *)notification {
  CGRect keyboardRect = [[notification userInfo][@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
  CGFloat inputBarOriginY = CGRectGetHeight(self.view.frame)-50-keyboardRect.size.height;
  inputBar.frame = CGRectMake(0, inputBarOriginY, CGRectGetWidth(inputBar.frame), 50);
  ///重新设置tableview高度
  CGRect tableviewNewRect = tableviewRect;
  tableviewNewRect.size.height -= (keyboardRect.size.height);
  tableView.frame = tableviewNewRect;
  [self scrollToBottomAnimate:true];
}

- (void)inputKeyboardWillHide:(NSNotification *)notification {
  CGRect inputBarFrame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 50);
  inputBarFrame.origin.y = CGRectGetHeight(self.view.frame)-50;
  inputBar.frame = inputBarFrame;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.chatMessageDicts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell * cell = [[UITableViewCell alloc] init];
  
  EMMessage * message = self.chatMessageDicts[indexPath.row];
  
  UILabel * nameLabel = [[UILabel alloc] init];
  nameLabel.text = [NSString stringWithFormat:@":%@",message.from];
  nameLabel.font = [UIFont systemFontOfSize:14];
  nameLabel.textColor = [UIColor orangeColor];
  [cell addSubview:nameLabel];
  
  CGSize size = [self getContentSizeWithFont:nameLabel.font size:CGSizeMake(60, 80)
                                     aString:nameLabel.text];
  
  /// 判断是自己的消息，放在右边
  if ([message.from isEqualToString:[EMClient sharedClient].currentUsername]) {
    
    nameLabel.frame = CGRectMake(SCREEN_WIDTH - size.width-10, 10, size.width, size.height);
    
    if (message.body.type == EMMessageBodyTypeText) {
      
      EMTextMessageBody * body = (EMTextMessageBody *)message.body;
      UILabel * textLabel = [[UILabel alloc] init];
      textLabel.text = body.text;
      textLabel.textAlignment = NSTextAlignmentRight;
      textLabel.font = [UIFont systemFontOfSize:14];
      textLabel.numberOfLines = 0;
      [cell addSubview:textLabel];
      CGSize textSize = [self getContentSizeWithFont:textLabel.font size:CGSizeMake(200, 1000) aString:textLabel.text];
      textLabel.frame = CGRectMake(SCREEN_WIDTH-size.width-15 - textSize.width, 10, textSize.width, textSize.height);
      
    } else if (message.body.type == EMMessageBodyTypeImage) {
      
    }
  } else {
    nameLabel.frame = CGRectMake(10, 10, size.width, size.height);
    if (message.body.type == EMMessageBodyTypeText) {
      
      EMTextMessageBody * body = (EMTextMessageBody *)message.body;
      UILabel * textLabel = [[UILabel alloc] init];
      textLabel.text = body.text;
      textLabel.textAlignment = NSTextAlignmentRight;
      textLabel.font = [UIFont systemFontOfSize:14];
      textLabel.numberOfLines = 0;
      [cell addSubview:textLabel];
      CGSize textSize = [self getContentSizeWithFont:textLabel.font size:CGSizeMake(200, 1000) aString:textLabel.text];
      textLabel.frame = CGRectMake(size.width+15 + textSize.width, 10, textSize.width, textSize.height);
      
    } else if (message.body.type == EMMessageBodyTypeImage) {
      
    }
  }
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  EMMessage * message = self.chatMessageDicts[indexPath.row];
  if (message.body.type == EMMessageBodyTypeText) {
    EMTextMessageBody * body = (EMTextMessageBody *)message.body;
    CGSize textSize = [self getContentSizeWithFont:[UIFont systemFontOfSize:14]
                                              size:CGSizeMake(200, 1000)
                                           aString:body.text];
    CGFloat height = textSize.height + 20;
    height = height < 50 ? 50 : height;
    return height;
  } else if (message.body.type == EMMessageBodyTypeImage) {
    
  }
  return 50;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:true];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  [inputBar endEditing:true];
}

- (void)scrollToBottomAnimate:(BOOL)animate {
  if (self.chatMessageDicts.count == 0) return;
  [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.chatMessageDicts.count-1 inSection:0]
                   atScrollPosition:UITableViewScrollPositionBottom
                           animated:animate];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  if (textField.text.length == 0) {
    return true;
  }
  [self sendMessageText:textField.text];
  return true;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
  tableView.frame = tableviewRect;
}

- (void)sendMessageText:(NSString *)text {
  EMTextMessageBody * textBody = [[EMTextMessageBody alloc] initWithText:text];
  NSString * from = [[EMClient sharedClient] currentUsername];
  
  EMMessage * message = [[EMMessage alloc] initWithConversationID:self.conversation.conversationId
                                                             from:from
                                                               to:self.toId
                                                             body:textBody
                                                              ext:nil]; //最后一个参数为扩展,附加内容
  message.chatType = EMChatTypeChat;
  [[EMClient sharedClient].chatManager asyncSendMessage:message progress:^(int progress) {
  } completion:^(EMMessage *message, EMError *error) {
    if (error == nil) {
      NSLog(@"发送成功");
    }
  }];
  inputTextField.text = @"";
  [self.chatMessageDicts addObject:message];
  [self.tableView reloadData];
  [self scrollToBottomAnimate:true];
}

- (CGSize)getContentSizeWithFont:(UIFont*)font size:(CGSize)size aString:(NSString *)aString {
  NSDictionary *attribute = @{NSFontAttributeName: font};
  CGSize result = [aString boundingRectWithSize:CGSizeMake(size.width, size.height)
                                     options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
  return result;
}

@end
